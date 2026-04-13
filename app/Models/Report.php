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
        'organization_id',
        'is_anonymous',
    ];

    public function organization()
    {
        return $this->belongsTo(Organization::class);
    }

    protected $casts = [
        'media_paths' => 'array',
        'is_anonymous' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
