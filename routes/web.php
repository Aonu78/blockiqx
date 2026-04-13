<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\AuthController; // Import AuthController for web auth
use App\Http\Controllers\StaffController;

// Public routes
Route::get('/', function () {
    return view('welcome');
});

// Authentication routes for community users
Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
Route::post('/login', [AuthController::class, 'login']);
Route::get('/register', [AuthController::class, 'showRegistrationForm'])->name('register');
Route::post('/register', [AuthController::class, 'register']);
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

// Password reset routes would typically go here if needed

// Admin routes - protected by 'web' guard
Route::prefix('admin')->middleware('auth:web')->group(function () {
    Route::get('/', function () {
        return view('admin');
    })->name('admin.dashboard');

    Route::get('/reports', [AdminController::class, 'reportsIndex'])->name('admin.reports');
    Route::get('/users', [AdminController::class, 'usersIndex'])->name('admin.users');
    Route::get('/staff', [AdminController::class, 'staffIndex'])->name('admin.staff');
    Route::get('/analytics', [AdminController::class, 'analyticsIndex'])->name('admin.analytics');
    Route::get('/map', [AdminController::class, 'mapIndex'])->name('admin.map');
    Route::get('/settings', [AdminController::class, 'settingsIndex'])->name('admin.settings');
    Route::post('/settings', [AdminController::class, 'updateProfile'])->name('admin.profile.update');
    
    // Actions for web dashboard
    Route::post('/reports/{report}/assign', [AdminController::class, 'assignReport'])->name('admin.reports.assign');
    Route::post('/staff/create', [AdminController::class, 'createOutreachMember'])->name('admin.staff.create');
    Route::put('/staff/{staff}/update', [AdminController::class, 'updateStaff'])->name('admin.staff.update');
    Route::post('/users/{user}/promote', [AdminController::class, 'promoteUserToStaff'])->name('admin.users.promote');
    Route::get('/staff/{staff}/impersonate', [AdminController::class, 'impersonateStaff'])->name('admin.staff.impersonate');
});

// Staff routes - protected by 'staff' guard
Route::prefix('staff')->middleware('auth:staff')->group(function () {
    Route::get('/reports', [\App\Http\Controllers\StaffController::class, 'reportsIndex'])->name('staff.reports');
    
    // Actions for staff panel
    Route::put('/reports/{report}/status', [\App\Http\Controllers\StaffController::class, 'updateReportStatus'])->name('staff.reports.status');
});
