// 
// Connection to the server (monitor modal)
// 
import React, { useEffect, useState } from "react";
import "../../assets/ConnectionModal.scss";
var count = 0;
export const ConnectionCheck = (props) => {
    const [isOnline, setOnline] = useState(true);
    const [retryCount, setRetryCount] = useState(0);
    useEffect(() => {
        setInterval(() => {
            fetch("http://" + window.location.host)
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
            return (React.createElement("div", null, props.children));
        }
        else {
            return (React.createElement("div", null,
                React.createElement("div", { className: "ConnectionModalApp" }, props.children),
                React.createElement("div", { className: "ConnectionModalBackdrop" }),
                React.createElement("div", { className: "ConnectionModal animated fadeIn" },
                    React.createElement("h1", null, "NO CONNECTION"),
                    React.createElement("h4", null, "Server Fault: Cannot Ping CJMS"),
                    React.createElement("h5", null,
                        "Retry Count: ",
                        retryCount))));
        }
    }
    return (AppRender());
};
