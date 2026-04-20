<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Notifications\DatabaseNotification;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user()
            ?? Auth::guard('sanctum')->user()
            ?? Auth::guard('web')->user()
            ?? Auth::guard('staff')->user();

        if (!$user) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }

        $notifications = $user->notifications()
            ->latest()
            ->take(50)
            ->get()
            ->map(function (DatabaseNotification $notification) {
                return [
                    'id' => $notification->id,
                    'read_at' => $notification->read_at,
                    'created_at' => $notification->created_at->toDateTimeString(),
                    'data' => $notification->data,
                ];
            });

        return response()->json(['notifications' => $notifications]);
    }

    public function markAsRead(Request $request, DatabaseNotification $notification)
    {
        $user = $request->user()
            ?? Auth::guard('sanctum')->user()
            ?? Auth::guard('web')->user()
            ?? Auth::guard('staff')->user();

        if (!$user || (string) $notification->notifiable_id !== (string) $user->getKey() || $notification->notifiable_type !== get_class($user)) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if (is_null($notification->read_at)) {
            $notification->markAsRead();
        }

        return response()->json([
            'id' => $notification->id,
            'read_at' => $notification->read_at,
        ]);
    }
}
