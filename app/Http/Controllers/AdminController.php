<?php

namespace App\Http\Controllers;

use App\Models\Report;
use App\Models\User;
use App\Models\Staff;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function getAllReports(Request $request)
    {
        $query = Report::query();

        if ($request->has('date')) {
            $query->whereDate('created_at', $request->date);
        }

        if ($request->has('area')) {
            // This assumes you have a way to filter by area.
            // We will add this functionality in a later step.
            $query->where('location', 'like', '%' . $request->area . '%');
        }

        if ($request->has('incident_type')) {
            $query->where('incident_type', $request->incident_type);
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $reports = $query->get();

        return response()->json($reports);
    }

    public function assignReport(Request $request, Report $report)
    {
        $validatedData = $request->validate([
            'staff_id' => 'required|exists:staff,id',
        ]);

        $report->update(['assigned_to' => $validatedData['staff_id']]);

        return response()->json([
            'message' => 'Report assigned successfully',
            'report' => $report
        ]);
    }

    public function getReportsOverview()
    {
        // This functionality will be implemented in a future step.
        return response()->json(['message' => 'Functionality not yet implemented.'], 501);
    }

    public function getAreaInsights()
    {
        // This functionality will be implemented in a future step.
        return response()->json(['message' => 'Functionality not yet implemented.'], 501);
    }

    public function getMapView()
    {
        // This functionality will be implemented in a future step.
        return response()->json(['message' => 'Functionality not yet implemented.'], 501);
    }

    public function getOutreachPerformance()
    {
        // This functionality will be implemented in a future step.
        return response()->json(['message' => 'Functionality not yet implemented.'], 501);
    }

    public function getAllUsers()
    {
        return response()->json(User::all());
    }

    public function createCommunityUser(Request $request)
    {
        // This functionality will be implemented in a future step.
        return response()->json(['message' => 'Functionality not yet implemented.'], 501);
    }

    public function getAllStaff()
    {
        return response()->json(Staff::all());
    }

    public function createOutreachMember(Request $request)
    {
        // This functionality will be implemented in a future step.
        return response()->json(['message' => 'Functionality not yet implemented.'], 501);
    }
}
