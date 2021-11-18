import React from "react";
import useState from "react";
import useEffect from "react";
import Axios from 'axios';
import sendTimeEvent from './mhub_handle';

import "./timer.css";

const userUpdateRequest = "http://localhost:3001/api/updateUser";


function test() {
	sendTimeEvent("whoop");
}

function MainApp() {
	return(
		// <div className='timer-container'>
		// 	<Timer
		// 	durationInSeconds={120}
		// 	formatted={true}
		// 	isPaused={false}
		// 	showPauseButton={true}
		// 	showResetButton={true}
			
		// 	onStart = {()=> {
		// 		console.log('Triggered when the timer starts')
		// 	}}
		// 	onPause = {(remainingDuration=0)=> {
		// 		console.log('Triggered when the timer is paused', remainingDuration)
		// 	}}
		// 	onFinish = {()=> {
		// 		console.log('Triggered when the timer finishes')
		// 	}}
		// 	onReset = {(remainingDuration=0)=> {
		// 		console.log('Triggered when the timer is reset', remainingDuration)
		// 	}}
		// 	onResume = {(remainingDuration=0)=> {
		// 		console.log('Triggered when the timer is resumed', remainingDuration)
		// 	}}
		// 	/>
		// </div>
		<form onSubmit={test}>
			<button className="buttonGreen" type="submit">Send that whoop</button>
		</form>
	);
}

export default MainApp;