const express = require('express');
const router = express.Router();
const expedientes = require('../controllers/expedientes.controller');
const indicios = require('../controllers/indicios.controller');

router.post('/expedientes', expedientes.crearExpediente);
router.post('/expedientes/:id/indicios', indicios.crearIndicio);
router.put('/expedientes/:id/estado', expedientes.cambiarEstado);

module.exports = router;
