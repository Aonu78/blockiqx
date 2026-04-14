<?php

namespace App\Http\Controllers;

use App\Models\Report;
use App\Models\User;
use App\Models\Staff;
use App\Models\Organization;
use Illuminate\Http\Request;
use App\Notifications\ReportAssigned;
use App\Notifications\ReportActivityNotification;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Redirect;
use Illuminate\Support\Facades\Route; // Although not used directly in this controller, it's good practice if routes are referenced.
use Illuminate\Support\Facades\Notification;
use Illuminate\Validation\ValidationException;
use Throwable;

class AdminController extends Controller
{
    // Methods for displaying admin views
    public function reportsIndex()
    {
        $reports = Report::with(['organization', 'assignedStaff'])->latest()->get();
        $staffMembers = Staff::with('organization')->orderBy('name')->get();

        return view('admin.reports', compact('reports', 'staffMembers'));
    }

    public function showReport(Report $report)
    {
        $report->load(['organization', 'assignedStaff', 'user']);
        $staffMembers = Staff::with('organization')->orderBy('name')->get();

        return view('admin.report-show', compact('report', 'staffMembers'));
    }

    public function usersIndex()
    {
        $users = User::latest()->get();
        return view('admin.users', compact('users'));
    }

    public function updateUser(Request $request, User $user)
    {
        $validatedData = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,' . $user->id,
            'password' => 'nullable|string|min:8|confirmed',
        ]);

        $user->name = $validatedData['name'];
        $user->email = $validatedData['email'];

        if (!empty($validatedData['password'])) {
            $user->password = Hash::make($validatedData['password']);
        }

        $user->save();

        if ($request->wantsJson()) {
            return response()->json(['message' => 'User updated successfully', 'user' => $user]);
        }

        return redirect()->route('admin.users')->with('success', 'User updated successfully');
    }

    public function staffIndex()
    {
        $staff = Staff::with('organization')->get(); // Eager load organization for display
        $organizations = Organization::orderBy('name')->get();

        return view('admin.staff', compact('staff', 'organizations'));
    }

    public function analyticsIndex()
    {
        return view('admin.analytics');
    }

    public function mapIndex()
    {
        // Fetch distinct incident types, statuses, and organizations for filter options
        $incidentTypes = Report::distinct('incident_type')->pluck('incident_type');
        $statuses = Report::distinct('status')->pluck('status');
        $organizations = Organization::all();

        return view('admin.map', compact('incidentTypes', 'statuses', 'organizations'));
    }

    // API methods for fetching data
    public function getAllReports(Request $request)
    {
        $query = Report::query();

        // Apply filters if provided
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

        return response()->json($reports);
    }

    public function getReportsOverview()
    {
        $totalReports = Report::count();
        $reportsByStatus = Report::select('status', \DB::raw('count(*) as count'))->groupBy('status')->get();
        $reportsByType = Report::select('incident_type', \DB::raw('count(*) as count'))->groupBy('incident_type')->get();

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

        // Fetch staff with their coordinates
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

    // Admin Settings
    public function settingsIndex()
    {
        $adminUser = Auth::user(); // Assuming admin uses the 'web' guard
        return view('admin.settings', compact('adminUser'));
    }

    public function updateProfile(Request $request)
    {
        $user = Auth::user();

        $validatedData = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,' . $user->id,
            'password' => 'nullable|string|min:8|confirmed', // Password is optional
        ]);

        $user->name = $validatedData['name'];
        $user->email = $validatedData['email'];
        if (!empty($validatedData['password'])) {
            $user->password = Hash::make($validatedData['password']);
        }

        $user->save();

        return redirect()->route('admin.settings')->with('success', 'Profile updated successfully!');
    }

    // Staff Management Actions
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
            'password' => Hash::make($validatedData['password']),
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
            'role' => 'nullable|string|exists:roles,name', // Assuming roles are managed via Spatie's Role model
        ]);

        $staff->update($validatedData);

        if (isset($validatedData['role'])) {
            $staff->syncRoles([$validatedData['role']]);
        }

        if ($request->wantsJson()) {
            return response()->json(['message' => 'Staff updated successfully', 'staff' => $staff]);
        }

        return redirect()->route('admin.staff')->with('success', 'Staff updated successfully');
    }

    public function promoteUserToStaff(Request $request, User $user)
    {
        if (Staff::where('email', $user->email)->exists()) {
            return redirect()->route('admin.users')->with('error', 'This user already exists in staff.');
        }

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

    public function assignReport(Request $request, Report $report)
    {
        $validatedData = $request->validate([
            'staff_id' => 'required|exists:staff,id',
        ]);

        $staff = Staff::findOrFail($validatedData['staff_id']);

        $report->update([
            'assigned_to' => $staff->id,
            'status' => $report->status === 'Pending' ? 'In Progress' : $report->status,
        ]);

        try {
            Notification::send($staff, new ReportAssigned($report->fresh()));
            Notification::send(
                User::role(['admin', 'super-admin'])->get(),
                new ReportActivityNotification(
                    'Report assigned',
                    'Report #' . $report->id . ' was assigned to ' . $staff->name . '.',
                    route('admin.reports.show', $report),
                    ['report_id' => $report->id, 'assigned_to' => $staff->id]
                )
            );
        } catch (Throwable $exception) {
            return redirect()->back()->with('warning', 'Report assigned, but the staff notification could not be sent.');
        }

        return redirect()->back()->with('success', 'Report assigned to ' . $staff->name . ' successfully.');
    }

    public function impersonateStaff(Staff $staff)
    {
        // This is a simple implementation for demo purposes
        \Auth::guard('staff')->login($staff);
        return redirect()->route('staff.reports');
    }

    // Staff Password Management
    public function resetStaffPassword(Request $request, Staff $staff)
    {
        $validatedData = $request->validate([
            'password' => 'required|string|min:8|confirmed',
        ]);

        $staff->update([
            'password' => Hash::make($validatedData['password']),
        ]);

        return redirect()->route('admin.staff')->with('success', 'Staff password reset successfully.');
    }
}
