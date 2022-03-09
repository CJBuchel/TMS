import ReactDOM from 'react-dom';
import React, {useState, useEffect} from 'react';
import { Shared } from '@cjms_interfaces/shared';

const NoInternetConnection = (props:any) => {
  // state variable holds the state of the internet connection
  const [isOnline, setOnline] = useState(true);

  var count = 0;
  useEffect(() => {
    setOnline(navigator.onLine);

    setInterval(() => {
      count++;
      fetch("http://"+window.location.host)
      .then(res => {
        setOnline(true);
      }).catch((error:any) => {
        setOnline(false);
      });
    }, 2000);

  },[]);

  // if user is online, return the child component else return a custom component
  if (isOnline) { 
    return (
      props.children
    )
  } else {
    return (
      <h1>No Internet Connection. Please try again later.</h1>
    )
  }
}

function App() {
  console.log(window.location.host);
  return (
    <div>
      <NoInternetConnection>Connection</NoInternetConnection>
    </div>
  );
}

export default App;

ReactDOM.render(
  <App/>,
  document.getElementById('root')
);