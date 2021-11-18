import React from 'react'

import './index.css'

function pad (number: any, length: any) {
	return (new Array(length + 1).join('0') + number).slice(-length)
}

function parseTime (time: number) {
	if (time <= 30) {
		return `${time | 0}`
	} else {
		return `${pad(Math.floor(time / 60), 2)}:${pad(time % 60, 2)}`
	}
}

export default function Clock (props: any) {
	return (
		<div className={`clock ${props.status}`}>
			{ parseTime(props.time) }
		</div>
	)
}