import { Login, useToken, CJMS_Application } from '@cjms_interfaces/shared';

import "./assets/application.scss";
import { Setup } from './components/Setup';
import useScorer from './components/Setup/useScorer';
import useTable from './components/Setup/useTable';
import Scoring from './Scoring';


/** Scoring Structure
 * two sets of identification which is stored in sessioncache
 * Main page should (eventually) be challenge scoring
 * Will have multiple pages for all matches, current table matches. And manual scoring
 */

function App() {
  const { token, setToken } = useToken();

  const { scorer, setScorer } = useScorer();
  const { table, setTable } = useTable();

  if (!token) {
    console.log("Token not made, redirecting...");
    return <Login setToken={setToken} allowedUsers={['scorekeeper', 'referee', 'head_referee']}/>
  } else {
    console.log("Token made");
    console.log(scorer);
    console.log(table);
    if (!table) {
      console.log("Table not defined redirecting...")
      return (
        <div className='scoring-app'>
          <Setup setScorer={setScorer} setTable={setTable}/>
        </div>
      );
    } else {
      return (
        <Scoring scorer={scorer} table={table}/>
      );
    }
  }
}

CJMS_Application(App);