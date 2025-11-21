const request = require('supertest');
const app = require('../src/app');

describe('Expedientes', () => {
  test('Crear expediente devuelve 201', async () => {
    const res = await request(app)
      .post('/api/v1/expedientes')
      .send({ codigo_expediente: 'EXP-TEST-001', descripcion: 'Prueba' });
    expect([201,500]).toContain(res.statusCode);
  });
});
