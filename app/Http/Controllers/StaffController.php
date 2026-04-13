<?php

namespace App\Http\Controllers;

use App\Models\Report;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class StaffController extends Controller
{
    public function getAssignedReports()
    {
        $staff = Auth::user();
        // This assumes you have a way to assign reports to staff members.
        // We will add this functionality in a later step.
        $reports = Report::where('assigned_to', $staff->id)->get();

        return response()->json($reports);
    }

    public function getReportDetails(Report $report)
    {
        return response()->json($report);
    }

    public function updateReportStatus(Request $request, Report $report)
    {
        $validatedData = $request->validate([
            'status' => 'required|string|in:In Progress,Completed,Arrived at location,Work started',
        ]);

        $report->update($validatedData);

        return response()->json([
            'message' => 'Report status updated successfully',
            'report' => $report
        ]);
    }

    public function addFieldNotes(Request $request, Report $report)
    {
        // This functionality will be implemented in a future step.
        return response()->json(['message' => 'Functionality not yet implemented.'], 501);
    }

    public function uploadMedia(Request $request, Report $report)
    {
        // This functionality will be implemented in a future step.
        return response()->json(['message' => 'Functionality not yet implemented.'], 501);
    }
}
