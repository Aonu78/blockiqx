<?php

namespace App\Observers;

use App\Models\Report;

use App\Models\Staff;
use App\Notifications\ReportAssigned;

class ReportObserver
{
    /**
     * Handle the Report "created" event.
     */
    public function created(Report $report): void
    {
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
        //
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
