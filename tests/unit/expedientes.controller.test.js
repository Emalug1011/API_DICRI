import { jest } from "@jest/globals";

// Mock mssql
jest.unstable_mockModule("mssql", () => ({
  default: {
    VarChar: jest.fn(),
    Int: jest.fn(),
    Date: jest.fn(),
  }
}));

// Mock DB service
jest.unstable_mockModule("../../src/services/db.service.js", () => ({
  poolPromise: Promise.resolve({
    request: () => ({
      input: jest.fn().mockReturnThis(),
      execute: jest.fn().mockResolvedValue({
        recordset: [{ id_expediente: 1, descripcion: "Test" }]
      })
    })
  })
}));

// Import controller DESPUÉS del mock
const { listarExpedientes } = await import(
  "../../src/controllers/expedientes.controller.js"
);

describe("listarExpedientes()", () => {
  test("Debe responder 200 y devolver un array", async () => {
    const req = { query: {} };
    const res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };

    await listarExpedientes(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(Array.isArray(res.json.mock.calls[0][0])).toBe(true);
  });
});
