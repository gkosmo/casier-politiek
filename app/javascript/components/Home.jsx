import React, { useState } from 'react';
import Hemicycle from './Hemicycle';
import FilterSidebar from './FilterSidebar';
import DetailPanel from './DetailPanel';

export default function Home({ politicians, stats }) {
  const [filters, setFilters] = useState({
    search: '',
    parties: [],
    dateRange: [1985, 2030],
    offenseTypes: [],
    appealStatuses: []
  });

  const [selectedPolitician, setSelectedPolitician] = useState(null);

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
    <div className="flex h-screen">
      <FilterSidebar
        filters={filters}
        setFilters={setFilters}
        stats={stats}
      />

      <div className="flex-1 flex flex-col">
        <div className="flex-1">
          <Hemicycle
            politicians={filteredPoliticians}
            onPoliticianClick={setSelectedPolitician}
          />
        </div>

        {selectedPolitician && (
          <DetailPanel
            politician={selectedPolitician}
            onClose={() => setSelectedPolitician(null)}
          />
        )}
      </div>
    </div>
  );
}
