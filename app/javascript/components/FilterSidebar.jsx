import React from 'react';

export default function FilterSidebar({ filters, setFilters, stats }) {
  const parties = Object.keys(stats.by_party);

  return (
    <div className="w-80 bg-gray-100 p-6 overflow-y-auto">
      <h2 className="text-2xl font-bold mb-6">Casier Politique Belgique</h2>

      <div className="mb-6">
        <label className="block text-sm font-medium mb-2">Search</label>
        <input
          type="text"
          className="w-full px-3 py-2 border rounded"
          placeholder="Politician name..."
          value={filters.search}
          onChange={(e) => setFilters({ ...filters, search: e.target.value })}
        />
      </div>

      <div className="mb-6">
        <label className="block text-sm font-medium mb-2">Date Range</label>
        <div className="flex gap-2">
          <input
            type="number"
            className="w-20 px-2 py-1 border rounded"
            value={filters.dateRange[0]}
            onChange={(e) => setFilters({
              ...filters,
              dateRange: [parseInt(e.target.value), filters.dateRange[1]]
            })}
          />
          <span>-</span>
          <input
            type="number"
            className="w-20 px-2 py-1 border rounded"
            value={filters.dateRange[1]}
            onChange={(e) => setFilters({
              ...filters,
              dateRange: [filters.dateRange[0], parseInt(e.target.value)]
            })}
          />
        </div>
      </div>

      <div className="mb-6">
        <label className="block text-sm font-medium mb-2">Parties</label>
        {parties.map(party => (
          <label key={party} className="flex items-center mb-2">
            <input
              type="checkbox"
              className="mr-2"
              checked={filters.parties.includes(party)}
              onChange={(e) => {
                if (e.target.checked) {
                  setFilters({ ...filters, parties: [...filters.parties, party] });
                } else {
                  setFilters({
                    ...filters,
                    parties: filters.parties.filter(p => p !== party)
                  });
                }
              }}
            />
            {party} ({stats.by_party[party]})
          </label>
        ))}
      </div>

      <div className="mb-6">
        <p className="text-sm text-gray-600">
          Total: {stats.total_convictions} convictions, {stats.total_politicians} politicians
        </p>
      </div>
    </div>
  );
}
