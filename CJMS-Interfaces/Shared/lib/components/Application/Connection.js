// 
// Connection to the server (monitor modal)
// 
import { comm_service } from "@cjms_shared/services";
import React, { useEffect, useState } from "react";
import "../../assets/stylesheets/ConnectionModal.scss";
var count = 0;
export const ConnectionCheck = (props) => {
    const [isOnline, setOnline] = useState(true);
    const [retryCount, setRetryCount] = useState(0);
    useEffect(() => {
        comm_service.listeners.onSystemRefresh(() => {
            console.log('refreshing');
            window.location.reload();
        });
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
            return (props.children);
        }
        else {
            var retryString = retryCount.toString();
            if (retryCount === 69) {
                retryString = retryString + " Nice";
            }
            return (React.createElement("div", { className: "ConnectionWrapper" },
                React.createElement("div", { className: "ConnectionModalApp" }, props.children),
                React.createElement("div", { className: "ConnectionModalBackdrop" }),
                React.createElement("div", { className: "ConnectionModal animated fadeIn" },
                    React.createElement("h1", null, "NO CONNECTION"),
                    React.createElement("h4", null, "Server Fault: Cannot Ping CJMS"),
                    React.createElement("h5", null,
                        "Retry Count: ",
                        retryString))));
        }
    }
    return (AppRender());
};
