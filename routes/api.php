<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\StaffControllerApi;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\AuthController;

Route::post('/login', [AuthController::class, 'userLogin']);
Route::post('/register', [AuthController::class, 'registerUser']);
Route::post('/staff/login', [AuthController::class, 'staffLogin']);

Route::post('/reports', [ReportController::class, 'store']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/reports/nearby', [ReportController::class, 'getNearbyResources']);
    
    Route::prefix('staff')->group(function () {
        Route::get('/reports', [StaffControllerApi::class, 'getAssignedReports']);
        Route::get('/reports/{report}', [StaffControllerApi::class, 'getReportDetails']);
        Route::put('/reports/{report}', [StaffControllerApi::class, 'updateReportStatus']);
        Route::post('/reports/{report}/notes', [StaffControllerApi::class, 'addFieldNotes']);
        Route::post('/reports/{report}/media', [StaffControllerApi::class, 'uploadMedia']);
    });
    Route::prefix('admin')->group(function () {
        Route::get('/reports', [AdminController::class, 'getAllReports']);
        Route::post('/reports/{report}/assign', [AdminController::class, 'assignReport']);
        Route::get('/analytics/reports-overview', [AdminController::class, 'getReportsOverview']);
        Route::get('/analytics/area-insights', [AdminController::class, 'getAreaInsights']);
        Route::get('/analytics/map-view', [AdminController::class, 'getMapView']);
        Route::get('/analytics/outreach-performance', [AdminController::class, 'getOutreachPerformance']);
        Route::get('/users', [AdminController::class, 'getAllUsers']);
        // Route::post('/users', [AdminController::class, 'createCommunityUser']); // This could be problematic if not carefully implemented
        Route::get('/staff', [AdminController::class, 'getAllStaff']);
        Route::post('/staff', [AdminController::class, 'createOutreachMember']);
    });

    Route::get('/notifications', [\App\Http\Controllers\Api\NotificationController::class, 'index']);
    Route::put('/notifications/{notification}/read', [\App\Http\Controllers\Api\NotificationController::class, 'markAsRead']);    Route::get('/notifications/stream', [\\App\\Http\\Controllers\\Api\\NotificationStreamController::class, 'stream']);});


