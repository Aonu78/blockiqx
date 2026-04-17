<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NotificationStreamController extends Controller
{
    public function stream(Request $request)
    {
        // Try API token auth first
        $user = Auth::guard('sanctum')->user();
        
        // Fallback to session auth if no API token
        if (!$user) {
            $user = Auth::guard('web')->user() ?? Auth::guard('staff')->user();
        }

        if (!$user) {
            return response('Unauthorized', 401);
        }

        return response()->stream(function () use ($user) {
            $lastNotificationId = $request->query('last_id', 0);

            while (true) {
                $notifications = $user->notifications()
                    ->where('id', '>', $lastNotificationId)
                    ->latest()
                    ->get();

                if ($notifications->isNotEmpty()) {
                    foreach ($notifications as $notification) {
                        echo "data: " . json_encode([
                            'id' => $notification->id,
                            'type' => 'notification',
                            'data' => $notification->data,
                            'created_at' => $notification->created_at->toDateTimeString(),
                        ]) . "\n\n";

                        $lastNotificationId = $notification->id;
                        ob_flush();
                        flush();
                    }
                }

                sleep(2); // Poll every 2 seconds
            }
        }, 200, [
            'Content-Type' => 'text/event-stream',
            'Cache-Control' => 'no-cache',
            'Connection' => 'keep-alive',
        ]);
    }
}
