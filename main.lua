-- Configuración inicial
display.setDefault("background", 0, 0.5, 1)

-- Variables globales
local ultimoIMC = nil
local historial = {}

-- -------------------------
-- Interfaz
-- -------------------------

-- Título
local titulo = display.newText({
    text = "Calculadora de IMC",
    x = display.contentCenterX,
    y = 40,
    font = native.systemFontBold,
    fontSize = 28
})

-- Campo peso
local fondoPeso = display.newRect(display.contentCenterX, 100, 280, 60)
fondoPeso:setFillColor(1,1,1,0.3)

local peso = native.newTextField(display.contentCenterX, 100, 280, 60)
peso.placeholder = "Peso (kg)"
peso.size = 22
peso:toFront()

-- Campo altura
local fondoAltura = display.newRect(display.contentCenterX, 180, 280, 60)
fondoAltura:setFillColor(1,1,1,0.3)

local altura = native.newTextField(display.contentCenterX, 180, 280, 60)
altura.placeholder = "Altura (m)"
altura.size = 22
altura:toFront()

-- Resultado y recomendación
local resultado = display.newText({text = "IMC: --", x = display.contentCenterX, y = 260, font = native.systemFontBold, fontSize = 22})
local recomendacion = display.newText({text = "", x = display.contentCenterX, y = 300, width = 280, align = "center", font = native.systemFont, fontSize = 18})

-- Medidor circular
local medidorFondo = display.newCircle(display.contentCenterX, 430, 60)
medidorFondo:setFillColor(0.2)

local medidor = display.newGroup()
local arco = display.newCircle(medidor, display.contentCenterX, 430, 55)
arco:setFillColor(0,0,0,0)
arco.strokeWidth = 14
arco:setStrokeColor(0.5)

-- Historial
local historialTexto = display.newText({text = "Historial:", x = display.contentCenterX, y = 570, width = 300, align = "center", font = native.systemFont, fontSize = 16})

-- Botones
local btnCalcular = display.newText("Calcular", display.contentCenterX, 350, native.systemFontBold, 24)
btnCalcular:setFillColor(0,0.8,0)

local btnEjemplo = display.newText("Ejemplo", display.contentCenterX-100, 510, native.systemFontBold, 22)
btnEjemplo:setFillColor(0,0.5,1)

local btnLimpiar = display.newText("Limpiar", display.contentCenterX+100, 510, native.systemFontBold, 22)
btnLimpiar:setFillColor(1,0.5,0)

-- -------------------------
-- Funciones de validación
-- -------------------------
local function validarDatos(p, h)
    if not p or not h then
        return false, "Usa solo números"
    end
    if p < 20 or p > 300 then
        return false, "Peso inválido (20-300 kg)"
    end
    if h < 1.2 or h > 2.2 then
        return false, "Altura inválida (1.2-2.2 m)"
    end
    return true
end

-- -------------------------
-- Función de cálculo del IMC
-- -------------------------
local function calcularIMC(p, h)
    local imc = p / (h*h)
    return math.floor(imc*10)/10
end

-- -------------------------
-- Función principal
-- -------------------------
local function procesarIMC()
    local p = tonumber(peso.text)
    local h = tonumber(altura.text)

    if peso.text == "" or altura.text == "" then
        resultado.text = "Completa todos los campos"
        return
    end

    local valido, mensaje = validarDatos(p, h)
    if not valido then
        resultado.text = mensaje
        return
    end

    local imc = calcularIMC(p, h)
    ultimoIMC = imc

    -- Determinar categoría y colores
    local categoria, r, g, b, mensajeRec = "",0,0,1,""
    if imc < 18.5 then
        categoria = "Bajo peso"
        r,g,b = 0,0,1
        mensajeRec = "Debes mejorar tu alimentación."
    elseif imc < 25 then
        categoria = "Peso normal"
        r,g,b = 0,1,0
        mensajeRec = "¡Buen trabajo! Mantén hábitos saludables."
    elseif imc < 30 then
        categoria = "Sobrepeso"
        r,g,b = 1,1,0
        mensajeRec = "Se recomienda hacer más ejercicio."
    else
        categoria = "Obesidad"
        r,g,b = 1,0,0
        mensajeRec = "Consulta con un especialista."
    end

    resultado.text = "IMC: "..imc.." ("..categoria..")"
    resultado:setFillColor(r,g,b)
    recomendacion.text = mensajeRec

    -- Animación del medidor
    arco:setStrokeColor(r,g,b)
    transition.to(arco,{time=400, xScale=1.2, yScale=1.2, onComplete=function()
        transition.to(arco,{time=300, xScale=1, yScale=1})
    end})

    -- Guardar historial
    table.insert(historial,1,imc)
    if #historial > 5 then table.remove(historial) end

    local texto = "Historial:\n"
    for i=1,#historial do
        texto = texto .. historial[i] .. "\n"
    end
    historialTexto.text = texto
end

-- -------------------------
-- Funciones auxiliares
-- -------------------------
local function ejemplo()
    peso.text = "70"
    altura.text = "1.70"
end

local function limpiar()
    peso.text = ""
    altura.text = ""
    resultado.text = "IMC: --"
    recomendacion.text = ""
    arco:setStrokeColor(0.5,0.5,0.5)
    historialTexto.text = "Historial:"
end

-- -------------------------
-- Eventos de botones
-- -------------------------
btnCalcular:addEventListener("tap", procesarIMC)
btnEjemplo:addEventListener("tap", ejemplo)
btnLimpiar:addEventListener("tap", limpiar)