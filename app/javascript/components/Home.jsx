import React, { useState, useEffect } from 'react';
import Header from './Header';
import StatsDashboard from './StatsDashboard';
import PartyLegend from './PartyLegend';
import Hemicycle from './Hemicycle';
import FilterSidebar from './FilterSidebar';
import DetailPanel from './DetailPanel';

export default function Home() {
  const [politicians, setPoliticians] = useState([]);
  const [stats, setStats] = useState({});
  const [loading, setLoading] = useState(true);

  const [filters, setFilters] = useState({
    search: '',
    parties: [],
    dateRange: [1985, 2030],
    offenseTypes: [],
    appealStatuses: []
  });

  const [selectedPolitician, setSelectedPolitician] = useState(null);

  useEffect(() => {
    fetch('/pages/data')
      .then(res => res.json())
      .then(data => {
        setPoliticians(data.politicians || []);
        setStats(data.stats || {});
        setLoading(false);
      })
      .catch(err => {
        console.error('Error fetching data:', err);
        setLoading(false);
      });
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-screen bg-gray-50">
        <div className="text-xl text-gray-600">Chargement...</div>
      </div>
    );
  }

  const filteredPoliticians = politicians.filter(politician => {
    if (filters.search && !politician.name.toLowerCase().includes(filters.search.toLowerCase())) {
      return false;
    }

    if (filters.parties.length > 0 && !filters.parties.includes(politician.party)) {
      return false;
    }

    return true;
  });

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      <Header />

      <div className="flex flex-1 overflow-hidden">
        {/* Sidebar - hidden on mobile, shown on desktop */}
        <div className="hidden lg:block lg:w-80 border-r border-gray-200 bg-white overflow-y-auto">
          <FilterSidebar
            filters={filters}
            setFilters={setFilters}
            stats={stats}
          />
        </div>

        {/* Main content */}
        <div className="flex-1 overflow-y-auto">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <StatsDashboard politicians={politicians} stats={stats} />
            <PartyLegend stats={stats} />

            {/* Hemicycle visualization */}
            <div className="bg-white rounded-lg shadow-md p-6 mb-6">
              <h2 className="text-2xl font-bold mb-4 text-gray-800">Hémicycle</h2>
              <div className="w-full" style={{ minHeight: '500px' }}>
                <Hemicycle
                  politicians={filteredPoliticians}
                  onPoliticianClick={setSelectedPolitician}
                />
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Detail panel as modal overlay */}
      {selectedPolitician && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-end sm:items-center justify-center z-50 p-0 sm:p-4">
          <div className="w-full sm:max-w-3xl sm:rounded-lg overflow-hidden max-h-full sm:max-h-[90vh]">
            <DetailPanel
              politician={selectedPolitician}
              onClose={() => setSelectedPolitician(null)}
            />
          </div>
        </div>
      )}
    </div>
  );
}
