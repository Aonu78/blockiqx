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
        $staff = Auth::user();

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

    public function getAssignedReports()
    {
        $staff = auth()->user();

        if (!$staff) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }

        $reports = Report::with(['organization', 'assignedStaff'])
            ->where('assigned_to', $staff->id)
            ->latest()
            ->get();

        return response()->json($reports);
    }

    public function getReportDetails(Report $report)
    {
        $report->load(['organization', 'assignedStaff', 'user']);

        return response()->json($report);
    }

    public function updateReportStatus(Request $request, Report $report)
    {
        $validatedData = $request->validate([
            'status' => 'required|string|in:In Progress,Completed,Arrived at location,Work started',
        ]);

        $report->update($validatedData);

        // Capture coordinates if status is 'Completed' and coordinates are available
        if ($validatedData['status'] === 'Completed' && $request->has('latitude') && $request->has('longitude')) {
            $report->update([
                'resolved_at_latitude' => $request->latitude,
                'resolved_at_longitude' => $request->longitude,
            ]);
        }

        broadcast(new \App\Events\ReportStatusUpdated($report))->toOthers();

        if ($request->wantsJson()) {
            return response()->json([
                'message' => 'Report status updated successfully',
                'report' => $report
            ]);
        }

        return redirect()->route('staff.reports')->with('success', 'Report status updated successfully');
    }

    public function addFieldNotes(Request $request, Report $report)
    {
        $validatedData = $request->validate([
            'notes' => 'required|string',
        ]);

        $notes = $report->notes ?? []; // Get existing notes or initialize empty array
        $notes[] = ['user_id' => Auth::user()->id(), 'note' => $validatedData['notes'], 'timestamp' => now()]; // Add new note with staff ID and timestamp
        
        $report->update(['notes' => $notes]);

        return response()->json(['message' => 'Note added successfully', 'report' => $report]);
    }

    public function uploadMedia(Request $request, Report $report)
    {
        $validatedData = $request->validate([
            'media.*' => 'required|file|mimes:jpg,jpeg,png,mp4,mov|max:20480', // Max 20MB per file
        ]);

        $mediaPaths = $report->media_paths ?? []; // Get existing paths or initialize empty array

        foreach ($request->file('media', []) as $file) {
            $path = $file->store('reports/media', 'public');
            $mediaPaths[] = $path;
        }
        
        $report->update(['media_paths' => $mediaPaths]);

        return response()->json(['message' => 'Media uploaded successfully', 'report' => $report]);
    }
}
