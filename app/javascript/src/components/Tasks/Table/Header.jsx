import React from "react";

const Header = () => (
  <thead>
    <tr>
      <th className="border-b border-r border-gray-300 bg-gray-100 px-4 py-2.5 text-left text-xs font-bold uppercase leading-4 text-gray-800">
        Tasks
      </th>
      <th className="border-b border-r border-gray-300 bg-gray-100 px-4 py-2.5 text-left text-xs font-bold uppercase leading-4 text-gray-800">
        Assigned To
      </th>
      <th className="w-2 border-b border-r border-gray-300 bg-gray-100 text-left text-xs font-bold uppercase leading-4 text-gray-800" />
    </tr>
  </thead>
);

export default Header;
