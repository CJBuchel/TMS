import { useState } from "react";

export default function useTable() {
  const getTable = () => {
    const tableString:any = sessionStorage.getItem('table');
    const valueTable = JSON.parse(tableString);
    if (valueTable && valueTable.table) {
      return valueTable.table;
    }
  }

  const [table, setTable] = useState(getTable());
  const saveTable = (valueTable:any) => {
    sessionStorage.setItem('table', JSON.stringify(valueTable));
    setTable(valueTable.table);
  }

  return { setTable: saveTable, table }
}