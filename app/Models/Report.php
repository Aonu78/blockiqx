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
        'description',
        'location',
        'media_path',
        'status',
        'user_id',
        'is_anonymous',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
