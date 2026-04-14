<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Report extends Model
{
    use HasFactory;

    protected $fillable = [
        'email',
        'phone_number',
        'incident_type',
        'category',
        'concern_level',
        'description',
        'location',
        'latitude',
        'longitude',
        'media_paths',
        'media_path',
        'status',
        'user_id',
        'assigned_to',
        'organization_id',
        'is_anonymous',
        'notes',
        'resolved_at_latitude',
        'resolved_at_longitude',
    ];

    public function organization()
    {
        return $this->belongsTo(Organization::class);
    }

    public function assignedStaff()
    {
        return $this->belongsTo(Staff::class, 'assigned_to');
    }

    protected $casts = [
        'media_paths' => 'array',
        'is_anonymous' => 'boolean',
        'notes' => 'array',
        'resolved_at_latitude' => 'decimal:8',
        'resolved_at_longitude' => 'decimal:8',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
