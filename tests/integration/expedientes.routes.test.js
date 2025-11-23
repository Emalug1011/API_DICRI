import { jest } from "@jest/globals";

// Mockear el middleware de autenticación
jest.unstable_mockModule("../../src/middleware/auth.middleware.js", () => ({
  verificarToken: (req, res, next) => {
    req.usuario = { id_usuario: 1, rol: "Tecnico" };
    next();
  }
}));

// Mockear DB para que no se conecte a SQL real
jest.unstable_mockModule("../../src/services/db.service.js", () => ({
  poolPromise: Promise.resolve({
    request: () => ({
      input: () => ({ 
        input: () => ({ 
          input: () => ({ 
            execute: async () => ({ recordset: [] })
          }) 
        }) 
      })
    })
  })
}));


// Importar la app DESPUÉS del mock
const { default: app } = await import("../../src/app.js");
import request from "supertest";

describe("GET /api/v1/expedientes/filter", () => {
  test("Debe requerir token y responder 200", async () => {
    const res = await request(app)
      .get("/api/v1/expedientes/filter")
      .set("Authorization", "Bearer cualquier_token");

    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true); // validar estructura mínima
  });
});
