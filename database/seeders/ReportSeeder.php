<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Report;
use App\Models\Staff;
use App\Models\Organization;

class ReportSeeder extends Seeder
{
    public function run()
    {
        $org = Organization::firstOrCreate(['name' => 'Default Organization']);
        $staff = Staff::first();

        $types = ['Medical Emergency', 'Theft', 'Vandalism', 'Public Nuisance', 'Other'];
        $locations = ['Downtown', 'North Park', 'East Side', 'West End', 'South Bay'];
        $statuses = ['Pending', 'In Progress', 'Completed', 'Arrived at location', 'Work started'];

        for ($i = 0; $i < 20; $i++) {
            Report::create([
                'email' => 'user' . $i . '@example.com',
                'phone_number' => '555-010' . $i,
                'incident_type' => $types[array_rand($types)],
                'description' => 'This is a sample description for report ' . $i,
                'location' => $locations[array_rand($locations)],
                'latitude' => 40.7128 + (rand(-100, 100) / 1000),
                'longitude' => -74.0060 + (rand(-100, 100) / 1000),
                'status' => $statuses[array_rand($statuses)],
                'assigned_to' => ($i % 2 == 0) ? $staff->id : null,
                'organization_id' => $org->id,
                'is_anonymous' => ($i % 5 == 0),
            ]);
        }
    }
}
