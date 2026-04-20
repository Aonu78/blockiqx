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

        return response()->stream(function () use ($user, $request) {
            $lastCreatedAt = $request->query('last_created_at');

            while (true) {
                $query = $user->notifications()->orderBy('created_at');

                if ($lastCreatedAt) {
                    $query->where('created_at', '>', $lastCreatedAt);
                }

                $notifications = $query->get();

                if ($notifications->isNotEmpty()) {
                    foreach ($notifications as $notification) {
                        echo "data: " . json_encode([
                            'id' => $notification->id,
                            'type' => 'notification',
                            'data' => $notification->data,
                            'read_at' => $notification->read_at?->toDateTimeString(),
                            'created_at' => $notification->created_at->toIso8601String(),
                        ]) . "\n\n";

                        $lastCreatedAt = $notification->created_at->toIso8601String();

                        if (ob_get_level() > 0) {
                            ob_flush();
                        }
                        flush();
                    }
                }

                echo ": heartbeat\n\n";
                if (ob_get_level() > 0) {
                    ob_flush();
                }
                flush();

                sleep(2);
            }
        }, 200, [
            'Content-Type' => 'text/event-stream',
            'Cache-Control' => 'no-cache',
            'Connection' => 'keep-alive',
        ]);
    }
}
