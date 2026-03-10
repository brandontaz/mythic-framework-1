import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Tab, Tabs, alpha, Button, TextField } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import { TabPanel, Dialog } from '../../components/UIComponents';
import { CurrencyFormat } from '../../util/Parser';
import { SavePed, CancelEdits, SaveImport } from '../../actions/pedActions';
import Clothes from '../../components/Clothes/Clothes';
import Accessories from '../../components/Accessories/Accessories';
import Body from '../../components/Body/Body';
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
	const cost = useSelector((state) => state.app.pricing.SHOP);
	const admin = useSelector((state) => state.app.admin || false);

	const [cancelling, setCancelling] = useState(false);
	const [saving, setSaving] = useState(false);
	const [value, setValue] = useState(0);
	const [importCode, setImportCode] = useState('');
	const [outfitName, setOutfitName] = useState('');

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

	const handleImport = () => {
		setImportCode('');
		setOpenImportDialog(true);
	};

	const handleCancelImport = () => {
		setOpenImportDialog(false);
		setCancelling(true);
	};

	const handleImportDialogClose = () => {
		setOpenImportDialog(false);
	};

	const handleImportCodeChange = (event) => {
		setImportCode(event.target.value);
	};

	const handleOutfitNameChange = (event) => {
		setOutfitName(event.target.value);
	};

	const handleImportConfirm = () => {
		setOpenImportDialog(false);
		dispatch(SaveImport(outfitName, importCode));
	};

	const [openImportDialog, setOpenImportDialog] = useState(false);
	const payLabel = admin
		? 'Save Everything'
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
							icon={<FontAwesomeIcon icon={['fas', 'shirt']} />}
							className={classes.tab}
						/>
						<Tab
							icon={
								<FontAwesomeIcon
									icon={['fas', 'hat-cowboy-side']}
								/>
							}
							className={classes.tab}
						/>
					</Tabs>
				</div>

				<div className={classes.panelBody}>
					<TabPanel value={value} index={0}>
						<Clothes />
					</TabPanel>
					<TabPanel value={value} index={1}>
						<Accessories />
					</TabPanel>
				</div>
			</div>

			<Naked />

			<div className={classes.saveBar}>
				<Button
					className={classes.btn}
					onClick={handleImport}
					startIcon={
						<FontAwesomeIcon icon={['fas', 'file-import']} />
					}
				>
					Import Outfit
				</Button>
				<Button
					className={`${classes.btn} ${classes.btnDanger}`}
					onClick={() => setCancelling(true)}
					startIcon={<FontAwesomeIcon icon={['fas', 'door-open']} />}
				>
					Leave Fitting Room
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
				open={openImportDialog}
				onClose={handleImportDialogClose}
				title="Import Code"
				onAccept={handleImportConfirm}
				onDecline={handleImportDialogClose}
				acceptLang="Import"
				declineLang="Cancel"
			>
				<TextField
					autoFocus
					margin="dense"
					id="outfit-name"
					label="Input Outfit Name"
					type="text"
					fullWidth
					value={outfitName}
					onChange={handleOutfitNameChange}
				/>
				<TextField
					autoFocus
					margin="dense"
					id="import-code"
					label="Input Outfit Code"
					type="text"
					fullWidth
					value={importCode}
					onChange={handleImportCodeChange}
				/>
			</Dialog>

			<Dialog
				title="Disregard Outfit?"
				open={cancelling}
				onAccept={onCancel}
				onDecline={() => setCancelling(false)}
				acceptLang="Yes, im sure"
				declineLang="Wait, no im not done"
			>
				<p>
					All changes will be discarded, are you sure you want to
					continue?
				</p>
			</Dialog>
			<Dialog
				title="Purchase Outfit?"
				open={saving}
				onAccept={onSave}
				onDecline={() => setSaving(false)}
				acceptLang="Yes, Im stylish"
				declineLang="NO, im ugly, take me back."
			>
				<p>
					You will be charged{' '}
					<span className={classes.highlight}>
						{CurrencyFormat.format(cost)}
					</span>
					?
				</p>
				<p>Are you sure you want to save?</p>
			</Dialog>
		</div>
	);
};
