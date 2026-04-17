<?php

namespace App\Observers;

use App\Models\Report;
use App\Models\Staff;
use App\Models\User;
use App\Events\ReportStatusUpdated;
use App\Notifications\ReportActivityNotification;
use App\Notifications\ReportAssigned;
use Illuminate\Support\Facades\Notification;

class ReportObserver
{
    /**
     * Handle the Report "created" event.
     */
    public function created(Report $report): void
    {
        Notification::send(
            User::role(['admin', 'super-admin'])->get(),
            new ReportActivityNotification(
                'New report submitted',
                'Report #' . $report->id . ' was submitted for ' . ($report->location ?: 'an unknown location') . '.',
                route('admin.reports.show', $report),
                ['report_id' => $report->id, 'status' => $report->status]
            )
        );

        // Auto-assign logic: find staff in the same location
        if (!$report->assigned_to) {
            $staff = Staff::where('location', $report->location)->first();
            
            if ($staff) {
                $report->update(['assigned_to' => $staff->id]);
                $staff->notify(new ReportAssigned($report));
            }
        }
    }

    /**
     * Handle the Report "updated" event.
     */
    public function updated(Report $report): void
    {
        if (!$report->wasChanged(['status', 'assigned_to', 'notes', 'media_paths'])) {
            return;
        }

        $admins = User::role(['admin', 'super-admin'])->get();

        if ($report->wasChanged('status')) {
            Notification::send(
                $admins,
                new ReportActivityNotification(
                    'Report status updated',
                    'Report #' . $report->id . ' is now ' . $report->status . '.',
                    route('admin.reports.show', $report),
                    ['report_id' => $report->id, 'status' => $report->status]
                )
            );

            if ($report->user) {
                $report->user->notify(new ReportActivityNotification(
                    'Report status updated',
                    'Your report #' . $report->id . ' is now ' . $report->status . '.',
                    null,
                    ['report_id' => $report->id, 'status' => $report->status]
                ));
            }
        }

        if ($report->wasChanged('assigned_to') && $report->assignedStaff) {
            Notification::send(
                $admins,
                new ReportActivityNotification(
                    'Report assigned',
                    'Report #' . $report->id . ' was assigned to ' . $report->assignedStaff->name . '.',
                    route('admin.reports.show', $report),
                    ['report_id' => $report->id, 'assigned_to' => $report->assigned_to]
                )
            );
        }

        if ($report->wasChanged('notes')) {
            Notification::send(
                $admins,
                new ReportActivityNotification(
                    'Field notes added',
                    'New field notes were added to report #' . $report->id . '.',
                    route('admin.reports.show', $report),
                    ['report_id' => $report->id]
                )
            );
        }

        if ($report->wasChanged('media_paths')) {
            Notification::send(
                $admins,
                new ReportActivityNotification(
                    'Report media updated',
                    'New media was uploaded for report #' . $report->id . '.',
                    route('admin.reports.show', $report),
                    ['report_id' => $report->id]
                )
            );
        }

        broadcast(new ReportStatusUpdated($report))->toOthers();
    }

    /**
     * Handle the Report "deleted" event.
     */
    public function deleted(Report $report): void
    {
        //
    }

    /**
     * Handle the Report "restored" event.
     */
    public function restored(Report $report): void
    {
        //
    }

    /**
     * Handle the Report "force deleted" event.
     */
    public function forceDeleted(Report $report): void
    {
        //
    }
}
