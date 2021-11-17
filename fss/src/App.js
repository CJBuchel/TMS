import './App.css';

function App() {
	return (
		<div className="App">
			<h1>FSS Application, use below links</h1>

			<div className="links">

				<label>Movie Name</label>
				<input type="text" name="name"/>

				<label>Review</label>
				<input type="text" name="review"/>
			</div>
		</div>
	);
}

export default App;