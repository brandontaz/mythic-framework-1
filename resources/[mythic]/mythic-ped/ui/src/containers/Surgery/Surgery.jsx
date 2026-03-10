import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Tab, Tabs, alpha, Button } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import { TabPanel, Dialog } from '../../components/UIComponents';
import { Face } from '../../components';
import { CurrencyFormat } from '../../util/Parser';
import { SavePed, CancelEdits } from '../../actions/pedActions';
import Body from '../../components/Body/Body';
import Hair from '../../components/Hair/Hair';
import Naked from '../../components/PedComponents/Naked';
import Nui from '../../util/Nui';
import CamBar from '../../components/UIComponents/CamBar';

const useStyles = makeStyles((theme) => ({
	save: {
		position: 'absolute',
		bottom: '1%',
		left: '1%',
		'& svg': {
			marginLeft: 6,
		},
	},
	panelShell: {
		position: 'absolute',
		right: 20,
		top: '4vh',
		width: 500,
		height: '92vh',
		display: 'flex',
		flexDirection: 'column',
		background: alpha(theme.palette.secondary.dark, 0.69),
		borderRadius: 10,
		overflow: 'hidden',
	},
	tabHeader: {
		flex: '0 0 auto',
		borderBottom: `1px solid ${alpha(theme.palette.primary.main, 0.18)}`,
	},
	tabs: {
		minHeight: 44,
	},
	tab: {
		minHeight: 44,
		minWidth: 60,
		padding: 0,
		textTransform: 'none',
		opacity: 0.85,
		'&.Mui-selected': {
			opacity: 1,
		},
		'& svg': {
			fontSize: 18,
		},
	},
	panelBody: {
		flex: '1 1 auto',
		overflowY: 'auto',
		padding: 12,
	},
	saveBar: {
		position: 'absolute',
		bottom: '1.5%',
		left: '1.5%',
		display: 'flex',
		gap: 8,
		padding: 8,
		borderRadius: 10,
	},
	btn: {
		minWidth: 110,
		height: 34,
		padding: '0 12px',
		borderRadius: 8,
		textTransform: 'none',
		fontSize: 14,
		fontWeight: 500,
		letterSpacing: 0,
		color: theme.palette.text.primary,
		background: alpha(theme.palette.primary.main, 0.35),
		border: `1px solid ${alpha(theme.palette.primary.main, 0.25)}`,
		boxShadow: 'none',
		transition:
			'background 120ms ease, transform 120ms ease, border-color 120ms ease',
		'&:hover': {
			background: alpha(theme.palette.primary.main, 0.45),
			borderColor: alpha(theme.palette.primary.main, 0.35),
			transform: 'translateY(-1px)',
			boxShadow: 'none',
		},
		'&:active': {
			transform: 'translateY(0px)',
		},
		'& .MuiButton-startIcon': {
			marginRight: 8,
		},
		'& .MuiButton-startIcon svg': {
			fontSize: 12,
			opacity: 0.85,
		},
	},
	btnPrimary: {
		background: alpha(theme.palette.success.main, 0.35),
		borderColor: alpha(theme.palette.success.main, 0.25),
		'&:hover': {
			background: alpha(theme.palette.success.main, 0.45),
			borderColor: alpha(theme.palette.success.main, 0.35),
		},
	},
	btnDanger: {
		background: alpha(theme.palette.error.main, 0.35),
		borderColor: alpha(theme.palette.error.main, 0.25),
		'&:hover': {
			background: alpha(theme.palette.error.main, 0.45),
			borderColor: alpha(theme.palette.error.main, 0.35),
		},
	},
}));

export default (props) => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const state = useSelector((state) => state.app.state);
	const cost = useSelector((state) => state.app.pricing.SURGERY);
	const admin = useSelector((state) => state.app.admin || false);

	const [cancelling, setCancelling] = useState(false);
	const [saving, setSaving] = useState(false);
	const [value, setValue] = useState(0);

	const handleChange = (event, newValue) => {
		setValue(newValue);
	};

	const onCancel = () => {
		setCancelling(false);
		dispatch(CancelEdits());
	};

	const onSave = () => {
		setSaving(false);
		dispatch(SavePed(state));
	};
	const payLabel = admin
		? "Ready, I'm not ugly anymore!"
		: `Pay ${CurrencyFormat.format(cost || 0)}`;

	return (
		<div>
			<CamBar />
			<div className={classes.panelShell}>
				<div className={classes.tabHeader}>
					<Tabs
						orientation="horizontal"
						value={value}
						onChange={handleChange}
						indicatorColor="primary"
						textColor="primary"
						variant="fullWidth"
						className={classes.tabs}
					>
						<Tab
							label={
								<FontAwesomeIcon
									icon={['fas', 'face-grimace']}
								/>
							}
						/>
						<Tab
							label={
								<FontAwesomeIcon
									icon={['fas', 'child-reaching']}
								/>
							}
						/>
						<Tab
							label={
								<FontAwesomeIcon icon={['fas', 'scissors']} />
							}
						/>
					</Tabs>
				</div>

				<div className={classes.panelBody}>
					<TabPanel value={value} index={0}>
						<Face />
					</TabPanel>
					<TabPanel value={value} index={1}>
						<Body />
					</TabPanel>
					<TabPanel value={value} index={2}>
						<Hair />
					</TabPanel>
				</div>
			</div>

			<Naked />
			<div className={classes.saveBar}>
				<Button
					className={`${classes.btn} ${classes.btnDanger}`}
					onClick={() => setCancelling(true)}
					startIcon={
						<FontAwesomeIcon icon={['fas', 'skull-crossbones']} />
					}
				>
					Abort Operation
				</Button>
				<Button
					className={`${classes.btn} ${classes.btnPrimary}`}
					onClick={() => setSaving(true)}
					startIcon={<FontAwesomeIcon icon={['fas', 'save']} />}
				>
					{payLabel}
				</Button>
			</div>

			<Dialog
				title="Leave Plastic Surgeon's Office?"
				open={cancelling}
				onAccept={onCancel}
				onDecline={() => setCancelling(false)}
				acceptLang="Yeah, I'm Beautiful Already"
				declineLang="Nah, I'm still ugly af."
			>
				<p>
					Any changes you've made will be lost. Are you sure you want
					to bail?
				</p>
			</Dialog>
			<Dialog
				title="Finalize Your New Look?"
				open={saving}
				onAccept={onSave}
				onDecline={() => setSaving(false)}
				acceptLang="Sculpt me, Doctor"
				declineLang="Nah, I'm still ugly af."
			>
				<p>
					{admin ? (
						<>
							This procedure is free — the surgeon said they need
							the practice.
						</>
					) : (
						<>
							This procedure will cost{' '}
							<span className={classes.highlight}>
								{CurrencyFormat.format(cost)}
							</span>
							.
						</>
					)}
				</p>
				<p>Ready to commit to the new look?</p>
			</Dialog>
		</div>
	);
};
