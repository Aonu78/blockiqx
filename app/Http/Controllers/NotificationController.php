<?php

namespace App\Http\Controllers;

use Illuminate\Http\RedirectResponse;
use Illuminate\Notifications\DatabaseNotification;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    public function open(DatabaseNotification $notification): RedirectResponse
    {
        $user = Auth::guard('staff')->user() ?? Auth::guard('web')->user();

        abort_unless(
            $user
            && (string) $notification->notifiable_id === (string) $user->getKey()
            && $notification->notifiable_type === get_class($user),
            403
        );

        if (is_null($notification->read_at)) {
            $notification->markAsRead();
        }

        return redirect($notification->data['url'] ?? url()->previous());
    }
}
