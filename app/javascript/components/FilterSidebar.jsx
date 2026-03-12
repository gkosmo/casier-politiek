import React from 'react';

export default function FilterSidebar({ filters, setFilters, stats }) {
  const parties = Object.keys(stats?.by_party || {});

  return (
    <div className="p-4 lg:p-6">
      <h3 className="text-xl font-bold mb-4 text-gray-800">Filtres</h3>

      {/* Search */}
      <div className="mb-6">
        <label className="block text-sm font-semibold text-gray-700 mb-2">
          Rechercher un élu
        </label>
        <input
          type="text"
          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          placeholder="Nom du politicien..."
          value={filters.search}
          onChange={(e) => setFilters({ ...filters, search: e.target.value })}
        />
      </div>

      {/* Date Range */}
      <div className="mb-6">
        <label className="block text-sm font-semibold text-gray-700 mb-2">
          Période
        </label>
        <div className="flex items-center gap-3">
          <input
            type="number"
            className="w-24 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent text-center"
            value={filters.dateRange[0]}
            onChange={(e) => setFilters({
              ...filters,
              dateRange: [parseInt(e.target.value) || 1985, filters.dateRange[1]]
            })}
          />
          <span className="text-gray-500">à</span>
          <input
            type="number"
            className="w-24 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent text-center"
            value={filters.dateRange[1]}
            onChange={(e) => setFilters({
              ...filters,
              dateRange: [filters.dateRange[0], parseInt(e.target.value) || 2030]
            })}
          />
        </div>
      </div>

      {/* Parties */}
      {parties.length > 0 && (
        <div className="mb-6">
          <label className="block text-sm font-semibold text-gray-700 mb-3">
            Partis politiques
          </label>
          <div className="space-y-2 max-h-64 overflow-y-auto">
            {parties.map(party => (
              <label key={party} className="flex items-center p-2 hover:bg-gray-50 rounded cursor-pointer transition-colors">
                <input
                  type="checkbox"
                  className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
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
                <span className="ml-3 text-sm text-gray-700 flex-1">
                  {party}
                </span>
                <span className="text-xs text-gray-500 bg-gray-100 px-2 py-1 rounded-full">
                  {stats?.by_party?.[party] || 0}
                </span>
              </label>
            ))}
          </div>
        </div>
      )}

      {/* Clear filters button */}
      {(filters.search || filters.parties.length > 0) && (
        <button
          onClick={() => setFilters({
            search: '',
            parties: [],
            dateRange: [1985, 2030],
            offenseTypes: [],
            appealStatuses: []
          })}
          className="w-full px-4 py-2 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-lg font-medium transition-colors"
        >
          Réinitialiser les filtres
        </button>
      )}
    </div>
  );
}
