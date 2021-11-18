import React from 'react';

interface LoginProps {
	whom?: string
}

const Login: React.FC<LoginProps> = ({ whom = 'World' }) => {
	return (
		<h1>Hello {whom}</h1>
	);
}

export default Login;