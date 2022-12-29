/**
 * 
 */
'use strict';

class TextInput extends React.Component {
	constructor(props) {
		super(props);
		this.state = {};
	}
/*	
	render() {
		return e(React.Fragment, {}, [
			e('td', 
				{key:1, className:'text-inp-r'}, 
				e('label', 
					{className:'label'}, 
					this.props.label
				)
			),
			e('td', 
				{key:2, className:'text-inp-l'}, 
				e('input', 
					{key:1,
					 className:'text-input',
					 autoComplete:'off',
					 onChange: this.props.onChange,
					 name:this.props.inpName,
					 type:this.props.inpType,
					 size:'25'
					}
				)
			)
		])
	}
*/
	render() {
		return e(React.Fragment, {}, [
			e('td', 
				{key:1, className:'text-inp-l'}, 
				e('label', 
					{className:'label'},
					[
						e('input', 
						{
							key:1,
							placeholder:".",
							className:'text-input',
							autoComplete:'off',
							onChange: this.props.onChange,
							name:this.props.inpName,
							type:this.props.inpType,
							size:'30'
						}),
						e('div', {key:2, style:{paddingLeft:'10px'}}, this.props.label)
					]
				)
			),
			e('td', {key:2, className:'text-inp-r'}, null)
		])
	}


}
