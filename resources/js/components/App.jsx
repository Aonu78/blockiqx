import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import AdminDashboard from './AdminDashboard';
import StaffDashboard from './StaffDashboard';

function App() {
    return (
        <Router>
            <Routes>
                <Route path="/admin" element={<AdminDashboard />} />
                <Route path="/staff" element={<StaffDashboard />} />
                <Route path="/" element={<Navigate to="/admin" />} />
            </Routes>
        </Router>
    );
}

export default App;
