<?php

namespace App\Http\Controllers;

use App\Models\Report;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Staff;

class StaffController extends Controller
{
    public function reportsIndex()
    {
        $staff = Auth::guard('staff')->user();

        if (!$staff) {
            $staff = Staff::first();
        }

        if (!$staff) {
             return view('staff.reports', ['reports' => []]);
        }

        $reports = Report::with(['organization', 'assignedStaff'])
            ->where('assigned_to', $staff->id)
            ->latest()
            ->get();

        return view('staff.reports', compact('reports'));
    }

    public function updateReportStatus(Request $request, Report $report)
    {
        $validatedData = $request->validate([
            'status' => 'required|string|in:Pending,In Progress,Completed,Arrived at location,Work started',
        ]);

        $staff = Auth::guard('staff')->user();

        abort_unless($staff && $report->assigned_to === $staff->id, 403);

        $report->update($validatedData);

        if ($validatedData['status'] === 'Completed' && $request->has('latitude') && $request->has('longitude')) {
            $report->update([
                'resolved_at_latitude' => $request->latitude,
                'resolved_at_longitude' => $request->longitude,
            ]);
        }

        if ($request->wantsJson()) {
            return response()->json([
                'message' => 'Report status updated successfully',
                'report' => $report
            ]);
        }

        return redirect()->route('staff.reports')->with('success', 'Report status updated successfully');
    }
}
