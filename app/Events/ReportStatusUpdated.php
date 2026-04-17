<?php

namespace App\Events;

use App\Models\Report;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ReportStatusUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $report;

    /**
     * Create a new event instance.
     */
    public function __construct(Report $report)
    {
        $this->report = $report;
    }

    public function broadcastAs(): string
    {
        return 'report.status.updated';
    }

    public function broadcastWith(): array
    {
        return [
            'type' => 'report.status.updated',
            'report' => [
                'id' => $this->report->id,
                'status' => $this->report->status,
                'assigned_to' => $this->report->assigned_to,
                'user_id' => $this->report->user_id,
                'incident_type' => $this->report->incident_type,
                'location' => $this->report->location,
                'description' => $this->report->description,
            ],
            'title' => 'Report status updated',
            'message' => 'Report #' . $this->report->id . ' is now ' . $this->report->status . '.',
            'target' => ['admin', 'staff', 'user'],
            'timestamp' => $this->report->updated_at?->toIsoString() ?? now()->toIsoString(),
        ];
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new Channel('reports'),
            new Channel('report.' . $this->report->id),
        ];
    }
}

