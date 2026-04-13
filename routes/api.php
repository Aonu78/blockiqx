<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\StaffController;
use App\Http\Controllers\AdminController;

Route::post('/reports', [ReportController::class, 'store']);

Route::middleware('auth:sanctum')->prefix('staff')->group(function () {
    Route::get('/reports', [StaffController::class, 'getAssignedReports']);
    Route::get('/reports/{report}', [StaffController::class, 'getReportDetails']);
    Route::put('/reports/{report}', [StaffController::class, 'updateReportStatus']);
    Route::post('/reports/{report}/notes', [StaffController::class, 'addFieldNotes']);
    Route::post('/reports/{report}/media', [StaffController::class, 'uploadMedia']);
});

Route::middleware('auth:sanctum')->prefix('admin')->group(function () {
    Route::get('/reports', [AdminController::class, 'getAllReports']);
    Route::post('/reports/{report}/assign', [AdminController::class, 'assignReport']);
    Route::get('/analytics/reports-overview', [AdminController::class, 'getReportsOverview']);
    Route::get('/analytics/area-insights', [AdminController::class, 'getAreaInsights']);
    Route::get('/analytics/map-view', [AdminController::class, 'getMapView']);
    Route::get('/analytics/outreach-performance', [AdminController::class, 'getOutreachPerformance']);
    Route::get('/users', [AdminController::class, 'getAllUsers']);
    Route::post('/users', [AdminController::class, 'createCommunityUser']);
    Route::get('/staff', [AdminController::class, 'getAllStaff']);
    Route::post('/staff', [AdminController::class, 'createOutreachMember']);
});
