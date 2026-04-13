<?php

namespace App\Http\Controllers;

use App\Models\Report;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ReportController extends Controller
{
    public function store(Request $request)
    {
        $validatedData = $request->validate([
            'email' => 'required_without:user_id|email',
            'phone_number' => 'required_without:user_id|string',
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

        if (Auth::check()) {
            $validatedData['user_id'] = Auth::id();
        } else {
            // Custom logic for guest users if needed
        }

        $report = Report::create($validatedData);

        broadcast(new \App\Events\ReportCreated($report))->toOthers();

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
}
