<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use App\Models\Report;
use App\Observers\ReportObserver;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\View;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Report::observe(ReportObserver::class);

        View::composer('components.navbar', function ($view) {
            $currentUser = Auth::guard('staff')->user() ?? Auth::guard('web')->user();

            $view->with([
                'navbarUser' => $currentUser,
                'navbarNotifications' => $currentUser ? $currentUser->notifications()->latest()->limit(8)->get() : collect(),
                'navbarUnreadNotificationsCount' => $currentUser ? $currentUser->unreadNotifications()->count() : 0,
                'navbarIsStaff' => Auth::guard('staff')->check(),
            ]);
        });
    }
}
