import { Injectable } from '@angular/core';
import { HubConnection, HubConnectionBuilder } from '@microsoft/signalr';
import { Subject, BehaviorSubject } from 'rxjs';

export interface PttMessage {
  userId: string;
  audioData: string;
  duration: number;
  timestamp: Date;
}

export interface UserStatus {
  type: 'joined' | 'left' | 'started_talking' | 'stopped_talking' | 'group_members';
  data: any;
}

@Injectable({
  providedIn: 'root'
})
export class PttService {
  private hubConnection: HubConnection | null = null;
  private mediaRecorder: MediaRecorder | null = null;
  private audioChunks: Blob[] = [];
  private currentGroup: string | null = null;
  private isRecording = false;

  // Subjects for events
  private audioReceivedSubject = new Subject<PttMessage>();
  private userStatusSubject = new Subject<UserStatus>();
  private connectionStatusSubject = new BehaviorSubject<boolean>(false);
  private recordingStatusSubject = new BehaviorSubject<boolean>(false);

  // Public observables
  public audioReceived$ = this.audioReceivedSubject.asObservable();
  public userStatus$ = this.userStatusSubject.asObservable();
  public connectionStatus$ = this.connectionStatusSubject.asObservable();
  public recordingStatus$ = this.recordingStatusSubject.asObservable();

  constructor() {}

  async initialize(token: string, serverUrl: string): Promise<void> {
    try {
      // Build SignalR connection
      this.hubConnection = new HubConnectionBuilder()
        .withUrl(`${serverUrl}/signalr-ptt`, {
          accessTokenFactory: () => token
        })
        .build();

      // Set up event handlers
      this.setupEventHandlers();

      // Start connection
      await this.hubConnection.start();
      this.connectionStatusSubject.next(true);
      console.log('Connected to PTT Hub');
    } catch (error) {
      console.error('Failed to connect to PTT Hub:', error);
      this.connectionStatusSubject.next(false);
      throw error;
    }
  }

  private setupEventHandlers(): void {
    if (!this.hubConnection) return;

    this.hubConnection.on('ReceiveAudio', (data: any) => {
      this.audioReceivedSubject.next({
        userId: data.userId,
        audioData: data.audioData,
        duration: data.duration,
        timestamp: new Date(data.timestamp)
      });
      
      // Auto-play received audio
      this.playAudio(data.audioData);
    });

    this.hubConnection.on('UserJoined', (data: any) => {
      this.userStatusSubject.next({
        type: 'joined',
        data: data
      });
    });

    this.hubConnection.on('UserLeft', (data: any) => {
      this.userStatusSubject.next({
        type: 'left',
        data: data
      });
    });

    this.hubConnection.on('UserStartedTalking', (data: any) => {
      this.userStatusSubject.next({
        type: 'started_talking',
        data: data
      });
    });

    this.hubConnection.on('UserStoppedTalking', (data: any) => {
      this.userStatusSubject.next({
        type: 'stopped_talking',
        data: data
      });
    });

    this.hubConnection.on('GroupMembers', (data: any) => {
      this.userStatusSubject.next({
        type: 'group_members',
        data: data
      });
    });
  }

  async joinGroup(groupName: string): Promise<void> {
    if (!this.hubConnection) throw new Error('Not connected to hub');
    
    this.currentGroup = groupName;
    await this.hubConnection.invoke('JoinGroup', groupName);
  }

  async leaveGroup(): Promise<void> {
    if (!this.hubConnection || !this.currentGroup) return;
    
    await this.hubConnection.invoke('LeaveGroup', this.currentGroup);
    this.currentGroup = null;
  }

  async startRecording(): Promise<void> {
    if (this.isRecording || !this.currentGroup) return;

    try {
      // Request microphone permission
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      
      // Notify group that user started talking
      await this.hubConnection?.invoke('StartTalking', this.currentGroup);

      // Set up MediaRecorder
      this.mediaRecorder = new MediaRecorder(stream);
      this.audioChunks = [];

      this.mediaRecorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          this.audioChunks.push(event.data);
        }
      };

      this.mediaRecorder.onstop = async () => {
        const audioBlob = new Blob(this.audioChunks, { type: 'audio/wav' });
        await this.sendAudioBlob(audioBlob);
        
        // Stop all tracks to release microphone
        stream.getTracks().forEach(track => track.stop());
      };

      this.mediaRecorder.start();
      this.isRecording = true;
      this.recordingStatusSubject.next(true);
      
      console.log('Started recording');
    } catch (error) {
      console.error('Failed to start recording:', error);
      throw error;
    }
  }

  async stopRecording(): Promise<void> {
    if (!this.isRecording || !this.mediaRecorder) return;

    try {
      this.mediaRecorder.stop();
      this.isRecording = false;
      this.recordingStatusSubject.next(false);

      // Notify group that user stopped talking
      await this.hubConnection?.invoke('StopTalking', this.currentGroup);
      
      console.log('Stopped recording');
    } catch (error) {
      console.error('Failed to stop recording:', error);
    }
  }

  private async sendAudioBlob(audioBlob: Blob): Promise<void> {
    try {
      // Convert blob to base64
      const base64Audio = await this.blobToBase64(audioBlob);
      
      // Calculate duration (simplified)
      const duration = Math.round(audioBlob.size / 16000); // Rough estimate

      // Send via SignalR
      await this.hubConnection?.invoke('SendAudioData', this.currentGroup, base64Audio, duration);
    } catch (error) {
      console.error('Failed to send audio:', error);
    }
  }

  private async playAudio(base64Audio: string): Promise<void> {
    try {
      // Convert base64 to blob
      const audioBlob = this.base64ToBlob(base64Audio, 'audio/wav');
      const audioUrl = URL.createObjectURL(audioBlob);
      
      // Create and play audio element
      const audio = new Audio(audioUrl);
      audio.onended = () => {
        URL.revokeObjectURL(audioUrl);
      };
      
      await audio.play();
    } catch (error) {
      console.error('Failed to play audio:', error);
    }
  }

  private blobToBase64(blob: Blob): Promise<string> {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => {
        const result = reader.result as string;
        // Remove data URL prefix
        const base64 = result.split(',')[1];
        resolve(base64);
      };
      reader.onerror = reject;
      reader.readAsDataURL(blob);
    });
  }

  private base64ToBlob(base64: string, mimeType: string): Blob {
    const byteCharacters = atob(base64);
    const byteNumbers = new Array(byteCharacters.length);
    
    for (let i = 0; i < byteCharacters.length; i++) {
      byteNumbers[i] = byteCharacters.charCodeAt(i);
    }
    
    const byteArray = new Uint8Array(byteNumbers);
    return new Blob([byteArray], { type: mimeType });
  }

  get isConnected(): boolean {
    return this.connectionStatusSubject.value;
  }

  get isCurrentlyRecording(): boolean {
    return this.isRecording;
  }

  get currentGroupName(): string | null {
    return this.currentGroup;
  }

  async disconnect(): Promise<void> {
    if (this.hubConnection) {
      await this.hubConnection.stop();
      this.connectionStatusSubject.next(false);
    }
  }
}
