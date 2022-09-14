import { CJMS_Application } from '@cjms_interfaces/shared';

import "./assets/application.scss";
import Display from './Display';

function App() {
  return (
    <Display/>
  );
}

CJMS_Application(App);