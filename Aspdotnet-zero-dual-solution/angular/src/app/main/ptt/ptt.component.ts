import { Component, OnInit, OnDestroy } from '@angular/core';
import { PttService, PttMessage, UserStatus } from '@shared/utils/ptt.service';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-ptt',
    templateUrl: './ptt.component.html',
    styleUrls: ['./ptt.component.css'],
})
export class PttComponent implements OnInit, OnDestroy {
    groupName: string = '';
    isConnected = false;
    isInGroup = false;
    isRecording = false;
    messages: any[] = [];
    groupMembers: any[] = [];
    talkingUsers: { [key: string]: boolean } = {};

    private subscriptions: Subscription[] = [];

    constructor(private pttService: PttService) {}

    async ngOnInit(): Promise<void> {
        await this.initializePtt();
        this.setupSubscriptions();
    }

    ngOnDestroy(): void {
        this.subscriptions.forEach((sub) => sub.unsubscribe());
        this.pttService.disconnect();
    }

    private async initializePtt(): Promise<void> {
        try {
            const token = abp.auth.getToken() || '';
            const serverUrl = 'https://localhost:44311'; // Update with your server URL

            await this.pttService.initialize(token, serverUrl);
        } catch (error) {
            console.error('Failed to initialize PTT:', error);
            abp.message.error('Failed to connect to PTT server');
        }
    }

    private setupSubscriptions(): void {
        // Connection status
        this.subscriptions.push(
            this.pttService.connectionStatus$.subscribe((connected) => {
                this.isConnected = connected;
            }),
        );

        // Recording status
        this.subscriptions.push(
            this.pttService.recordingStatus$.subscribe((recording) => {
                this.isRecording = recording;
            }),
        );

        // Audio received
        this.subscriptions.push(
            this.pttService.audioReceived$.subscribe((message) => {
                this.handleAudioReceived(message);
            }),
        );

        // User status changes
        this.subscriptions.push(
            this.pttService.userStatus$.subscribe((status) => {
                this.handleUserStatusChange(status);
            }),
        );
    }

    private handleAudioReceived(message: PttMessage): void {
        this.messages.push({
            type: 'audio',
            userId: message.userId,
            duration: message.duration,
            timestamp: message.timestamp,
        });
    }

    private handleUserStatusChange(status: UserStatus): void {
        switch (status.type) {
            case 'joined':
                this.messages.push({
                    type: 'system',
                    message: status.data.message,
                    timestamp: new Date(),
                });
                break;
            case 'left':
                this.messages.push({
                    type: 'system',
                    message: status.data.message,
                    timestamp: new Date(),
                });
                break;
            case 'started_talking':
                this.talkingUsers[status.data.userId] = true;
                break;
            case 'stopped_talking':
                this.talkingUsers[status.data.userId] = false;
                break;
            case 'group_members':
                this.groupMembers = status.data;
                break;
        }
    }

    async joinGroup(): Promise<void> {
        if (!this.groupName.trim()) {
            abp.message.warn('Please enter a group name');
            return;
        }

        try {
            await this.pttService.joinGroup(this.groupName);
            this.isInGroup = true;
            this.messages = [];
            this.groupMembers = [];
            this.talkingUsers = {};
            abp.message.success('Joined group successfully');
        } catch (error) {
            console.error('Failed to join group:', error);
            abp.message.error('Failed to join group');
        }
    }

    async leaveGroup(): Promise<void> {
        try {
            await this.pttService.leaveGroup();
            this.isInGroup = false;
            this.groupName = '';
            this.messages = [];
            this.groupMembers = [];
            this.talkingUsers = {};
            abp.message.success('Left group successfully');
        } catch (error) {
            console.error('Failed to leave group:', error);
            abp.message.error('Failed to leave group');
        }
    }

    async startTalking(): Promise<void> {
        try {
            await this.pttService.startRecording();
        } catch (error) {
            console.error('Failed to start recording:', error);
            abp.message.error('Failed to start recording. Please check microphone permissions.');
        }
    }

    async stopTalking(): Promise<void> {
        try {
            await this.pttService.stopRecording();
        } catch (error) {
            console.error('Failed to stop recording:', error);
        }
    }

    onPttMouseDown(): void {
        if (this.isInGroup && !this.isRecording) {
            this.startTalking();
        }
    }

    onPttMouseUp(): void {
        if (this.isRecording) {
            this.stopTalking();
        }
    }

    onPttMouseLeave(): void {
        if (this.isRecording) {
            this.stopTalking();
        }
    }

    getConnectionStatusClass(): string {
        return this.isConnected ? 'alert-success' : 'alert-danger';
    }

    getConnectionStatusText(): string {
        return this.isConnected ? 'Connected to PTT Server' : 'Disconnected from PTT Server';
    }

    getPttButtonClass(): string {
        if (!this.isInGroup) return 'btn-secondary';
        return this.isRecording ? 'btn-danger' : 'btn-primary';
    }

    getPttButtonText(): string {
        if (!this.isInGroup) return 'Join a group first';
        return this.isRecording ? 'Release to stop' : 'Hold to talk';
    }

    formatTime(date: Date): string {
        return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    }
}
