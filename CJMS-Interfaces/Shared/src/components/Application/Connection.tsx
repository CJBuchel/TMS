// 
// Connection to the server (monitor modal)
// 
import React, { useEffect, useState }  from "react";
import "../../assets/stylesheets/ConnectionModal.scss";

var count = 0;
export const ConnectionCheck = (props:any) => {
  const [isOnline, setOnline] = useState(true);
  const [retryCount, setRetryCount] = useState(0);
  useEffect(() => {
    setInterval(() => {
      fetch("http://"+window.location.host)
      .then(res => {
        setOnline(true);
        count = 0;
        setRetryCount(0);
      }).catch((error) => {
        count++;
        setRetryCount(count);
        setOnline(false);
      });
    }, 2000);
  }, []);

  function AppRender() {

    // If there is a connection to server render normally
    if (isOnline) {
      return (
        <div>{props.children}</div>
      )
    } else {
      var retryString = retryCount.toString();
      if (retryCount === 69) {
        retryString = retryString + " Nice";
      }

      return (
        <div className="ConnectionWrapper">
          <div className="ConnectionModalApp">{props.children}</div>
          <div className="ConnectionModalBackdrop"></div>
          <div className="ConnectionModal animated fadeIn">
            <h1>NO CONNECTION</h1>
            <h4>Server Fault: Cannot Ping CJMS</h4>
            <h5>Retry Count: {retryString}</h5>
          </div>
        </div>
      )
    }
  }

  return (
    AppRender()
  )
}