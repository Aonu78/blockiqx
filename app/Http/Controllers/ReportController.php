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
            'media_path' => 'nullable|string',
            'is_anonymous' => 'boolean',
        ]);

        if (Auth::check()) {
            $validatedData['user_id'] = Auth::id();
        } else {
            // Custom logic for guest users if needed
        }

        $report = Report::create($validatedData);

        return response()->json([
            'message' => 'Report created successfully',
            'report_id' => $report->id
        ], 201);
    }
}
