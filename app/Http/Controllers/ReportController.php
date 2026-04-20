<?php

namespace App\Http\Controllers;

use App\Models\Report;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Throwable;

class ReportController extends Controller
{
    public function store(Request $request)
    {
        $authenticatedUser = $request->user()
            ?? Auth::guard('sanctum')->user()
            ?? Auth::guard('web')->user();

        $validatedData = $request->validate([
            'email' => $authenticatedUser ? 'nullable|email' : 'required|email',
            'phone_number' => $authenticatedUser ? 'nullable|string' : 'required|string',
            'incident_type' => 'required|string',
            'description' => 'required|string',
            'location' => 'required|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'media.*' => 'nullable|file|mimes:jpg,jpeg,png,mp4,mov|max:20480',
            'is_anonymous' => 'boolean',
        ]);

        if ($request->hasFile('media')) {
            $mediaPaths = [];
            foreach ($request->file('media') as $file) {
                $path = $file->store('reports/media', 'public');
                $mediaPaths[] = $path;
            }
            $validatedData['media_paths'] = $mediaPaths;
        }

        if ($authenticatedUser) {
            $validatedData['user_id'] = $authenticatedUser->id;
            $validatedData['email'] = $validatedData['email'] ?? $authenticatedUser->email;
        }

        $report = Report::create($validatedData);

        try {
            broadcast(new \App\Events\ReportCreated($report))->toOthers();
        } catch (Throwable $exception) {
            report($exception);
        }

        return response()->json([
            'message' => 'Report created successfully',
            'report_id' => $report->id
        ], 201);
    }

    public function getNearbyResources(Request $request)
    {
        // For demonstration, returning a sample set of resources
        // In a real application, this would use the user's location to filter resources
        $resources = [
            [
                'id' => 1,
                'name' => 'Community Center A',
                'location' => 'Central Area',
                'services' => ['Medical Help', 'Shelter'],
                'distance' => '0.5km'
            ],
            [
                'id' => 2,
                'name' => 'Support Hub B',
                'location' => 'North Area',
                'services' => ['Legal Advice', 'Food Bank'],
                'distance' => '1.2km'
            ]
        ];

        return response()->json($resources);
    }

    public function getUserReports(Request $request)
    {
        $reports = Report::where('user_id', $request->user()->id)->get();
        return response()->json($reports);
    }

    public function updateUserReport(Request $request, Report $report)
    {
        if ($request->user()->id !== $report->user_id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($report->status !== 'Pending') {
            return response()->json(['message' => 'This report can no longer be edited.'], 403);
        }

        $validatedData = $request->validate([
            'incident_type' => 'required|string',
            'description' => 'required|string',
            'location' => 'required|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
        ]);

        $report->update($validatedData);

        return response()->json($report);
    }
}
