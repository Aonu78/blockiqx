<?php

namespace App\Http\Controllers;

use App\Models\Report;
use App\Models\User;
use App\Models\Staff;
use App\Models\Organization; // Import the Organization model
use Illuminate\Http\Request;
use App\Notifications\ReportAssigned;

class AdminController extends Controller
{
    public function reportsIndex()
    {
        $reports = Report::all();
        return view('admin.reports', compact('reports'));
    }

    public function usersIndex()
    {
        $users = User::all();
        return view('admin.users', compact('users'));
    }

    public function staffIndex()
    {
        $staff = Staff::all();
        return view('admin.staff', compact('staff'));
    }

    public function analyticsIndex()
    {
        return view('admin.analytics');
    }

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
        
        $staff = Staff::find($validatedData['staff_id']);
        $staff->notify(new ReportAssigned($report));

        if ($request->wantsJson()) {
            return response()->json([
                'message' => 'Report assigned successfully',
                'report' => $report
            ]);
        }

        return redirect()->route('admin.reports')->with('success', 'Report assigned successfully');
    }

    public function getReportsOverview()
    {
        $totalReports = Report::count();
        $reportsByStatus = Report::select('status', \DB::raw('count(*) as count'))
            ->groupBy('status')
            ->get();
        $reportsByType = Report::select('incident_type', \DB::raw('count(*) as count'))
            ->groupBy('incident_type')
            ->get();

        return response()->json([
            'total_reports' => $totalReports,
            'by_status' => $reportsByStatus,
            'by_type' => $reportsByType,
        ]);
    }

    public function getAreaInsights()
    {
        $areaInsights = Report::select('location', \DB::raw('count(*) as count'))
            ->groupBy('location')
            ->orderBy('count', 'desc')
            ->get();

        return response()->json($areaInsights);
    }

    public function mapIndex()
    {
        // Fetch distinct incident types and statuses for filter options
        $incidentTypes = Report::distinct('incident_type')->pluck('incident_type');
        $statuses = Report::distinct('status')->pluck('status');
        // Fetch organizations for filtering
        $organizations = Organization::all();

        return view('admin.map', compact('incidentTypes', 'statuses', 'organizations'));
    }

    public function getMapView(Request $request)
    {
        $query = Report::query();

        // Apply filters
        if ($request->has('status') && $request->status != 'all') {
            $query->where('status', $request->status);
        }

        if ($request->has('incident_type') && $request->incident_type != 'all') {
            $query->where('incident_type', $request->incident_type);
        }

        if ($request->has('date_from')) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }

        if ($request->has('date_to')) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }
        
        if ($request->has('organization_id') && $request->organization_id != 'all') {
            $query->where('organization_id', $request->organization_id);
        }

        // Select and fetch reports with coordinates and relevant details
        $reports = $query->whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->select('id', 'incident_type', 'location', 'latitude', 'longitude', 'status', 'description', 'category', 'concern_level', 'organization_id')
            ->get();

        // Fetch staff with their locations (assuming staff has latitude/longitude if needed)
        // For now, using the string location field as defined in staff model.
        // If staff also have lat/long, they should be fetched and returned here.
        $staff = Staff::whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->select('id', 'name', 'location', 'organization_id', 'latitude', 'longitude')
            ->get();

        return response()->json([
            'reports' => $reports,
            'staff' => $staff
        ]);
    }

    public function getOutreachPerformance()
    {
        $performance = Staff::withCount(['reports' => function($query) {
            $query->where('status', 'Completed');
        }])->get();

        return response()->json($performance);
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
        $validatedData = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:staff',
            'password' => 'required|string|min:8',
            'organization_id' => 'nullable|exists:organizations,id',
            'location' => 'nullable|string',
        ]);

        $staff = Staff::create([
            'name' => $validatedData['name'],
            'email' => $validatedData['email'],
            'password' => bcrypt($validatedData['password']),
            'organization_id' => $validatedData['organization_id'] ?? null,
            'location' => $validatedData['location'] ?? null,
        ]);

        $staff->assignRole('staff');

        if ($request->wantsJson()) {
            return response()->json(['message' => 'Staff created successfully', 'staff' => $staff], 201);
        }

        return redirect()->route('admin.staff')->with('success', 'Staff created successfully');
    }

    public function updateStaff(Request $request, Staff $staff)
    {
        $validatedData = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:staff,email,' . $staff->id,
            'organization_id' => 'nullable|exists:organizations,id',
            'location' => 'nullable|string',
            'role' => 'nullable|string|exists:roles,name',
        ]);

        $staff->update($validatedData);

        if (isset($validatedData['role'])) {
            $staff->syncRoles([$validatedData['role']]);
        }

        return redirect()->route('admin.staff')->with('success', 'Staff updated successfully');
    }

    public function promoteUserToStaff(Request $request, User $user)
    {
        // Create staff record from user data
        $staff = Staff::create([
            'name' => $user->name,
            'email' => $user->email,
            'password' => $user->password, // Keep same password hash
            'location' => $request->location ?? null,
            'organization_id' => $request->organization_id ?? null,
        ]);

        $staff->assignRole('staff');
        
        // Optionally delete or deactivate the user record
        // $user->delete();

        return redirect()->route('admin.staff')->with('success', 'User promoted to staff successfully');
    }

    public function impersonateStaff(Staff $staff)
    {
        // This is a simple implementation for demo purposes
        \Auth::guard('staff')->login($staff);
        return redirect()->route('staff.reports');
    }
}
