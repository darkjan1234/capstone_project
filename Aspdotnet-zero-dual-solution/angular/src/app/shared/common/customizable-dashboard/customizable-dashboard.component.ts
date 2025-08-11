import { Component, ChangeDetectionStrategy, Input } from '@angular/core';

@Component({
    selector: 'customizable-dashboard',
    templateUrl: './customizable-dashboard.component.html',
    // no styleUrls — all styles are inline in the HTML template
    changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CustomizableDashboardComponent {
    @Input() dashboardName?: string; // optional, para dili mo-error sa parent binding
}
