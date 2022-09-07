import { useState } from "react";

export default function useTable() {
  const getTable = () => {
    const tableString:any = sessionStorage.getItem('table');
    const userTable = JSON.parse(tableString);
    if (userTable && userTable.table) {
      return userTable.table;
    }
  }

  const [table, setTable] = useState(getTable());
  const saveTable = (valueTable:string) => {
    sessionStorage.setItem('table', JSON.stringify(valueTable));
    setTable(valueTable);
  }

  return { setTable: saveTable, table }
}