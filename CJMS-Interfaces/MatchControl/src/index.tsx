import { CJMS_Application, Login, useToken } from '@cjms_interfaces/shared';

import "./assets/stylesheets/application.scss";
import Display from './Display';

function App() {
  const { token, setToken } = useToken();

  if (!token) {
    console.log("Token not made, redirecting...");
    return <Login setToken={setToken} allowedUsers={['head_referee']}></Login>
  } else {
    console.log("Token made");
    return (
      <Display/>
    );
  }
}

CJMS_Application(App);