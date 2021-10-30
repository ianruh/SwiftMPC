// Created 2020 github @ianruh

#if !NO_NUMERIC_OBJECTIVE
import LASwift
@_exported import RealModule
import SwiftMPC

extension LTVNumericObjective: Objective {
    var numVariables: Int { return 180 }
    var numConstraints: Int { return 120 }

    //=================== Extractors ===================

    @inlinable
    static func extractVector_vehicleAngle(_ x: Vector) -> Vector {
        var flat: Vector = zeros(30)
        flat.withUnsafeMutableBufferPointer { buffer in
            buffer[0] = x[2]
            buffer[1] = x[8]
            buffer[2] = x[14]
            buffer[3] = x[20]
            buffer[4] = x[26]
            buffer[5] = x[32]
            buffer[6] = x[38]
            buffer[7] = x[44]
            buffer[8] = x[50]
            buffer[9] = x[56]
            buffer[10] = x[62]
            buffer[11] = x[68]
            buffer[12] = x[74]
            buffer[13] = x[80]
            buffer[14] = x[86]
            buffer[15] = x[92]
            buffer[16] = x[98]
            buffer[17] = x[104]
            buffer[18] = x[110]
            buffer[19] = x[116]
            buffer[20] = x[122]
            buffer[21] = x[128]
            buffer[22] = x[134]
            buffer[23] = x[140]
            buffer[24] = x[146]
            buffer[25] = x[152]
            buffer[26] = x[158]
            buffer[27] = x[164]
            buffer[28] = x[170]
            buffer[29] = x[176]
        }
        return flat
    }

    @inlinable
    static func extractVector_yPosition(_ x: Vector) -> Vector {
        var flat: Vector = zeros(30)
        flat.withUnsafeMutableBufferPointer { buffer in
            buffer[0] = x[1]
            buffer[1] = x[7]
            buffer[2] = x[13]
            buffer[3] = x[19]
            buffer[4] = x[25]
            buffer[5] = x[31]
            buffer[6] = x[37]
            buffer[7] = x[43]
            buffer[8] = x[49]
            buffer[9] = x[55]
            buffer[10] = x[61]
            buffer[11] = x[67]
            buffer[12] = x[73]
            buffer[13] = x[79]
            buffer[14] = x[85]
            buffer[15] = x[91]
            buffer[16] = x[97]
            buffer[17] = x[103]
            buffer[18] = x[109]
            buffer[19] = x[115]
            buffer[20] = x[121]
            buffer[21] = x[127]
            buffer[22] = x[133]
            buffer[23] = x[139]
            buffer[24] = x[145]
            buffer[25] = x[151]
            buffer[26] = x[157]
            buffer[27] = x[163]
            buffer[28] = x[169]
            buffer[29] = x[175]
        }
        return flat
    }

    @inlinable
    static func extractVector_steeringAngle(_ x: Vector) -> Vector {
        var flat: Vector = zeros(30)
        flat.withUnsafeMutableBufferPointer { buffer in
            buffer[0] = x[4]
            buffer[1] = x[10]
            buffer[2] = x[16]
            buffer[3] = x[22]
            buffer[4] = x[28]
            buffer[5] = x[34]
            buffer[6] = x[40]
            buffer[7] = x[46]
            buffer[8] = x[52]
            buffer[9] = x[58]
            buffer[10] = x[64]
            buffer[11] = x[70]
            buffer[12] = x[76]
            buffer[13] = x[82]
            buffer[14] = x[88]
            buffer[15] = x[94]
            buffer[16] = x[100]
            buffer[17] = x[106]
            buffer[18] = x[112]
            buffer[19] = x[118]
            buffer[20] = x[124]
            buffer[21] = x[130]
            buffer[22] = x[136]
            buffer[23] = x[142]
            buffer[24] = x[148]
            buffer[25] = x[154]
            buffer[26] = x[160]
            buffer[27] = x[166]
            buffer[28] = x[172]
            buffer[29] = x[178]
        }
        return flat
    }

    @inlinable
    static func extractVector_acceleration(_ x: Vector) -> Vector {
        var flat: Vector = zeros(30)
        flat.withUnsafeMutableBufferPointer { buffer in
            buffer[0] = x[5]
            buffer[1] = x[11]
            buffer[2] = x[17]
            buffer[3] = x[23]
            buffer[4] = x[29]
            buffer[5] = x[35]
            buffer[6] = x[41]
            buffer[7] = x[47]
            buffer[8] = x[53]
            buffer[9] = x[59]
            buffer[10] = x[65]
            buffer[11] = x[71]
            buffer[12] = x[77]
            buffer[13] = x[83]
            buffer[14] = x[89]
            buffer[15] = x[95]
            buffer[16] = x[101]
            buffer[17] = x[107]
            buffer[18] = x[113]
            buffer[19] = x[119]
            buffer[20] = x[125]
            buffer[21] = x[131]
            buffer[22] = x[137]
            buffer[23] = x[143]
            buffer[24] = x[149]
            buffer[25] = x[155]
            buffer[26] = x[161]
            buffer[27] = x[167]
            buffer[28] = x[173]
            buffer[29] = x[179]
        }
        return flat
    }

    @inlinable
    static func extractVector_xPosition(_ x: Vector) -> Vector {
        var flat: Vector = zeros(30)
        flat.withUnsafeMutableBufferPointer { buffer in
            buffer[0] = x[0]
            buffer[1] = x[6]
            buffer[2] = x[12]
            buffer[3] = x[18]
            buffer[4] = x[24]
            buffer[5] = x[30]
            buffer[6] = x[36]
            buffer[7] = x[42]
            buffer[8] = x[48]
            buffer[9] = x[54]
            buffer[10] = x[60]
            buffer[11] = x[66]
            buffer[12] = x[72]
            buffer[13] = x[78]
            buffer[14] = x[84]
            buffer[15] = x[90]
            buffer[16] = x[96]
            buffer[17] = x[102]
            buffer[18] = x[108]
            buffer[19] = x[114]
            buffer[20] = x[120]
            buffer[21] = x[126]
            buffer[22] = x[132]
            buffer[23] = x[138]
            buffer[24] = x[144]
            buffer[25] = x[150]
            buffer[26] = x[156]
            buffer[27] = x[162]
            buffer[28] = x[168]
            buffer[29] = x[174]
        }
        return flat
    }

    @inlinable
    static func extractVector_forwardVelocity(_ x: Vector) -> Vector {
        var flat: Vector = zeros(30)
        flat.withUnsafeMutableBufferPointer { buffer in
            buffer[0] = x[3]
            buffer[1] = x[9]
            buffer[2] = x[15]
            buffer[3] = x[21]
            buffer[4] = x[27]
            buffer[5] = x[33]
            buffer[6] = x[39]
            buffer[7] = x[45]
            buffer[8] = x[51]
            buffer[9] = x[57]
            buffer[10] = x[63]
            buffer[11] = x[69]
            buffer[12] = x[75]
            buffer[13] = x[81]
            buffer[14] = x[87]
            buffer[15] = x[93]
            buffer[16] = x[99]
            buffer[17] = x[105]
            buffer[18] = x[111]
            buffer[19] = x[117]
            buffer[20] = x[123]
            buffer[21] = x[129]
            buffer[22] = x[135]
            buffer[23] = x[141]
            buffer[24] = x[147]
            buffer[25] = x[153]
            buffer[26] = x[159]
            buffer[27] = x[165]
            buffer[28] = x[171]
            buffer[29] = x[177]
        }
        return flat
    }

    //=================== Objective Value ===================
    @inlinable
    func value(_ x: Vector) -> Double {
        return x[174] * -1.0 + x[177] * -1.0
    }

    //=================== Gradient Value ===================
    @inlinable
    func gradient(_: Vector) -> Vector {
        var flat: Vector = zeros(180)
        flat.withUnsafeMutableBufferPointer { buffer in
            buffer[174] = -1.0
            buffer[177] = -1.0
        }
        return flat
    }

    //=================== Hessian Value ===================
    @inlinable
    func hessian(_: Vector) -> Matrix {
        var flat: Vector = zeros(32400)
        flat.withUnsafeMutableBufferPointer { _ in
        }
        return Matrix(180, 180, flat)
    }

    //=================== Equality Matrix Constraint ===================
    var equalityConstraintMatrix: Matrix? {
        var flat: Vector = zeros(21600)
        flat.withUnsafeMutableBufferPointer { buffer in
            buffer[0] = 1.0
            buffer[181] = 1.0
            buffer[362] = 1.0
            buffer[543] = 1.0
            buffer[720] = -1.0 * 1.0
            buffer[722] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[1] + self.previousAngle[1]) + Double
                        .sin(self.previousSteeringAngle[1] + self.previousAngle[1]) * -1.0 *
                        (-1.0 * self.previousAngle[1] + 1.0)) * 0.1 *
                    self.previousVelocity[1])
            buffer[726] = 1.0
            buffer[901] = -1.0 * 1.0
            buffer[902] = -1.0 *
                (((-1.0 * self.previousAngle[1] + 1.0) * Double
                        .cos(self.previousSteeringAngle[1] + self.previousAngle[1]) + Double
                        .sin(self.previousSteeringAngle[1] + self.previousAngle[1])) * 0.1 * self
                                        .previousVelocity[1])
            buffer[907] = 1.0
            buffer[1082] = -1.0 * 1.0
            buffer[1084] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[1] + 1.0) * Double
                        .cos(self.previousSteeringAngle[1]) + Double
                        .sin(self.previousSteeringAngle[1])) * 0.1 * self.previousVelocity[1])
            buffer[1088] = 1.0
            buffer[1263] = -1.0 * 1.0
            buffer[1265] = -1.0 * 0.1
            buffer[1269] = 1.0
            buffer[1446] = -1.0 * 1.0
            buffer[1448] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[2] + self.previousAngle[2]) + Double
                        .sin(self.previousSteeringAngle[2] + self.previousAngle[2]) * -1.0 *
                        (-1.0 * self.previousAngle[2] + 1.0)) * 0.1 *
                    self.previousVelocity[2])
            buffer[1452] = 1.0
            buffer[1627] = -1.0 * 1.0
            buffer[1628] = -1.0 *
                (((-1.0 * self.previousAngle[2] + 1.0) * Double
                        .cos(self.previousSteeringAngle[2] + self.previousAngle[2]) + Double
                        .sin(self.previousSteeringAngle[2] + self.previousAngle[2])) * 0.1 * self
                                        .previousVelocity[2])
            buffer[1633] = 1.0
            buffer[1808] = -1.0 * 1.0
            buffer[1810] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[2] + 1.0) * Double
                        .cos(self.previousSteeringAngle[2]) + Double
                        .sin(self.previousSteeringAngle[2])) * 0.1 * self.previousVelocity[2])
            buffer[1814] = 1.0
            buffer[1989] = -1.0 * 1.0
            buffer[1991] = -1.0 * 0.1
            buffer[1995] = 1.0
            buffer[2172] = -1.0 * 1.0
            buffer[2174] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[3] + self.previousAngle[3]) + Double
                        .sin(self.previousSteeringAngle[3] + self.previousAngle[3]) * -1.0 *
                        (-1.0 * self.previousAngle[3] + 1.0)) * 0.1 *
                    self.previousVelocity[3])
            buffer[2178] = 1.0
            buffer[2353] = -1.0 * 1.0
            buffer[2354] = -1.0 *
                (((-1.0 * self.previousAngle[3] + 1.0) * Double
                        .cos(self.previousSteeringAngle[3] + self.previousAngle[3]) + Double
                        .sin(self.previousSteeringAngle[3] + self.previousAngle[3])) * 0.1 * self
                                        .previousVelocity[3])
            buffer[2359] = 1.0
            buffer[2534] = -1.0 * 1.0
            buffer[2536] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[3] + 1.0) * Double
                        .cos(self.previousSteeringAngle[3]) + Double
                        .sin(self.previousSteeringAngle[3])) * 0.1 * self.previousVelocity[3])
            buffer[2540] = 1.0
            buffer[2715] = -1.0 * 1.0
            buffer[2717] = -1.0 * 0.1
            buffer[2721] = 1.0
            buffer[2898] = -1.0 * 1.0
            buffer[2900] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[4] + self.previousAngle[4]) + Double
                        .sin(self.previousSteeringAngle[4] + self.previousAngle[4]) * -1.0 *
                        (-1.0 * self.previousAngle[4] + 1.0)) * 0.1 *
                    self.previousVelocity[4])
            buffer[2904] = 1.0
            buffer[3079] = -1.0 * 1.0
            buffer[3080] = -1.0 *
                (((-1.0 * self.previousAngle[4] + 1.0) * Double
                        .cos(self.previousSteeringAngle[4] + self.previousAngle[4]) + Double
                        .sin(self.previousSteeringAngle[4] + self.previousAngle[4])) * 0.1 * self
                                        .previousVelocity[4])
            buffer[3085] = 1.0
            buffer[3260] = -1.0 * 1.0
            buffer[3262] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[4] + 1.0) * Double
                        .cos(self.previousSteeringAngle[4]) + Double
                        .sin(self.previousSteeringAngle[4])) * 0.1 * self.previousVelocity[4])
            buffer[3266] = 1.0
            buffer[3441] = -1.0 * 1.0
            buffer[3443] = -1.0 * 0.1
            buffer[3447] = 1.0
            buffer[3624] = -1.0 * 1.0
            buffer[3626] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[5] + self.previousAngle[5]) + Double
                        .sin(self.previousSteeringAngle[5] + self.previousAngle[5]) * -1.0 *
                        (-1.0 * self.previousAngle[5] + 1.0)) * 0.1 *
                    self.previousVelocity[5])
            buffer[3630] = 1.0
            buffer[3805] = -1.0 * 1.0
            buffer[3806] = -1.0 *
                (((-1.0 * self.previousAngle[5] + 1.0) * Double
                        .cos(self.previousSteeringAngle[5] + self.previousAngle[5]) + Double
                        .sin(self.previousSteeringAngle[5] + self.previousAngle[5])) * 0.1 * self
                                        .previousVelocity[5])
            buffer[3811] = 1.0
            buffer[3986] = -1.0 * 1.0
            buffer[3988] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[5] + 1.0) * Double
                        .cos(self.previousSteeringAngle[5]) + Double
                        .sin(self.previousSteeringAngle[5])) * 0.1 * self.previousVelocity[5])
            buffer[3992] = 1.0
            buffer[4167] = -1.0 * 1.0
            buffer[4169] = -1.0 * 0.1
            buffer[4173] = 1.0
            buffer[4350] = -1.0 * 1.0
            buffer[4352] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[6] + self.previousAngle[6]) + Double
                        .sin(self.previousSteeringAngle[6] + self.previousAngle[6]) * -1.0 *
                        (-1.0 * self.previousAngle[6] + 1.0)) * 0.1 *
                    self.previousVelocity[6])
            buffer[4356] = 1.0
            buffer[4531] = -1.0 * 1.0
            buffer[4532] = -1.0 *
                (((-1.0 * self.previousAngle[6] + 1.0) * Double
                        .cos(self.previousSteeringAngle[6] + self.previousAngle[6]) + Double
                        .sin(self.previousSteeringAngle[6] + self.previousAngle[6])) * 0.1 * self
                                        .previousVelocity[6])
            buffer[4537] = 1.0
            buffer[4712] = -1.0 * 1.0
            buffer[4714] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[6] + 1.0) * Double
                        .cos(self.previousSteeringAngle[6]) + Double
                        .sin(self.previousSteeringAngle[6])) * 0.1 * self.previousVelocity[6])
            buffer[4718] = 1.0
            buffer[4893] = -1.0 * 1.0
            buffer[4895] = -1.0 * 0.1
            buffer[4899] = 1.0
            buffer[5076] = -1.0 * 1.0
            buffer[5078] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[7] + self.previousAngle[7]) + Double
                        .sin(self.previousSteeringAngle[7] + self.previousAngle[7]) * -1.0 *
                        (-1.0 * self.previousAngle[7] + 1.0)) * 0.1 *
                    self.previousVelocity[7])
            buffer[5082] = 1.0
            buffer[5257] = -1.0 * 1.0
            buffer[5258] = -1.0 *
                (((-1.0 * self.previousAngle[7] + 1.0) * Double
                        .cos(self.previousSteeringAngle[7] + self.previousAngle[7]) + Double
                        .sin(self.previousSteeringAngle[7] + self.previousAngle[7])) * 0.1 * self
                                        .previousVelocity[7])
            buffer[5263] = 1.0
            buffer[5438] = -1.0 * 1.0
            buffer[5440] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[7] + 1.0) * Double
                        .cos(self.previousSteeringAngle[7]) + Double
                        .sin(self.previousSteeringAngle[7])) * 0.1 * self.previousVelocity[7])
            buffer[5444] = 1.0
            buffer[5619] = -1.0 * 1.0
            buffer[5621] = -1.0 * 0.1
            buffer[5625] = 1.0
            buffer[5802] = -1.0 * 1.0
            buffer[5804] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[8] + self.previousAngle[8]) + Double
                        .sin(self.previousSteeringAngle[8] + self.previousAngle[8]) * -1.0 *
                        (-1.0 * self.previousAngle[8] + 1.0)) * 0.1 *
                    self.previousVelocity[8])
            buffer[5808] = 1.0
            buffer[5983] = -1.0 * 1.0
            buffer[5984] = -1.0 *
                (((-1.0 * self.previousAngle[8] + 1.0) * Double
                        .cos(self.previousSteeringAngle[8] + self.previousAngle[8]) + Double
                        .sin(self.previousSteeringAngle[8] + self.previousAngle[8])) * 0.1 * self
                                        .previousVelocity[8])
            buffer[5989] = 1.0
            buffer[6164] = -1.0 * 1.0
            buffer[6166] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[8] + 1.0) * Double
                        .cos(self.previousSteeringAngle[8]) + Double
                        .sin(self.previousSteeringAngle[8])) * 0.1 * self.previousVelocity[8])
            buffer[6170] = 1.0
            buffer[6345] = -1.0 * 1.0
            buffer[6347] = -1.0 * 0.1
            buffer[6351] = 1.0
            buffer[6528] = -1.0 * 1.0
            buffer[6530] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[9] + self.previousAngle[9]) + Double
                        .sin(self.previousSteeringAngle[9] + self.previousAngle[9]) * -1.0 *
                        (-1.0 * self.previousAngle[9] + 1.0)) * 0.1 *
                    self.previousVelocity[9])
            buffer[6534] = 1.0
            buffer[6709] = -1.0 * 1.0
            buffer[6710] = -1.0 *
                (((-1.0 * self.previousAngle[9] + 1.0) * Double
                        .cos(self.previousSteeringAngle[9] + self.previousAngle[9]) + Double
                        .sin(self.previousSteeringAngle[9] + self.previousAngle[9])) * 0.1 * self
                                        .previousVelocity[9])
            buffer[6715] = 1.0
            buffer[6890] = -1.0 * 1.0
            buffer[6892] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[9] + 1.0) * Double
                        .cos(self.previousSteeringAngle[9]) + Double
                        .sin(self.previousSteeringAngle[9])) * 0.1 * self.previousVelocity[9])
            buffer[6896] = 1.0
            buffer[7071] = -1.0 * 1.0
            buffer[7073] = -1.0 * 0.1
            buffer[7077] = 1.0
            buffer[7254] = -1.0 * 1.0
            buffer[7256] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[10] + self.previousAngle[10]) + Double
                        .sin(self.previousSteeringAngle[10] + self.previousAngle[10]) * -1.0 *
                        (-1.0 * self.previousAngle[10] + 1.0)) * 0.1 *
                    self.previousVelocity[10])
            buffer[7260] = 1.0
            buffer[7435] = -1.0 * 1.0
            buffer[7436] = -1.0 *
                (((-1.0 * self.previousAngle[10] + 1.0) * Double
                        .cos(self.previousSteeringAngle[10] + self.previousAngle[10]) + Double
                        .sin(self.previousSteeringAngle[10] + self.previousAngle[10])) * 0.1 * self
                                        .previousVelocity[10])
            buffer[7441] = 1.0
            buffer[7616] = -1.0 * 1.0
            buffer[7618] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[10] + 1.0) * Double
                        .cos(self.previousSteeringAngle[10]) + Double
                        .sin(self.previousSteeringAngle[10])) * 0.1 * self.previousVelocity[10])
            buffer[7622] = 1.0
            buffer[7797] = -1.0 * 1.0
            buffer[7799] = -1.0 * 0.1
            buffer[7803] = 1.0
            buffer[7980] = -1.0 * 1.0
            buffer[7982] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[11] + self.previousAngle[11]) + Double
                        .sin(self.previousSteeringAngle[11] + self.previousAngle[11]) * -1.0 *
                        (-1.0 * self.previousAngle[11] + 1.0)) * 0.1 *
                    self.previousVelocity[11])
            buffer[7986] = 1.0
            buffer[8161] = -1.0 * 1.0
            buffer[8162] = -1.0 *
                (((-1.0 * self.previousAngle[11] + 1.0) * Double
                        .cos(self.previousSteeringAngle[11] + self.previousAngle[11]) + Double
                        .sin(self.previousSteeringAngle[11] + self.previousAngle[11])) * 0.1 * self
                                        .previousVelocity[11])
            buffer[8167] = 1.0
            buffer[8342] = -1.0 * 1.0
            buffer[8344] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[11] + 1.0) * Double
                        .cos(self.previousSteeringAngle[11]) + Double
                        .sin(self.previousSteeringAngle[11])) * 0.1 * self.previousVelocity[11])
            buffer[8348] = 1.0
            buffer[8523] = -1.0 * 1.0
            buffer[8525] = -1.0 * 0.1
            buffer[8529] = 1.0
            buffer[8706] = -1.0 * 1.0
            buffer[8708] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[12] + self.previousAngle[12]) + Double
                        .sin(self.previousSteeringAngle[12] + self.previousAngle[12]) * -1.0 *
                        (-1.0 * self.previousAngle[12] + 1.0)) * 0.1 *
                    self.previousVelocity[12])
            buffer[8712] = 1.0
            buffer[8887] = -1.0 * 1.0
            buffer[8888] = -1.0 *
                (((-1.0 * self.previousAngle[12] + 1.0) * Double
                        .cos(self.previousSteeringAngle[12] + self.previousAngle[12]) + Double
                        .sin(self.previousSteeringAngle[12] + self.previousAngle[12])) * 0.1 * self
                                        .previousVelocity[12])
            buffer[8893] = 1.0
            buffer[9068] = -1.0 * 1.0
            buffer[9070] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[12] + 1.0) * Double
                        .cos(self.previousSteeringAngle[12]) + Double
                        .sin(self.previousSteeringAngle[12])) * 0.1 * self.previousVelocity[12])
            buffer[9074] = 1.0
            buffer[9249] = -1.0 * 1.0
            buffer[9251] = -1.0 * 0.1
            buffer[9255] = 1.0
            buffer[9432] = -1.0 * 1.0
            buffer[9434] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[13] + self.previousAngle[13]) + Double
                        .sin(self.previousSteeringAngle[13] + self.previousAngle[13]) * -1.0 *
                        (-1.0 * self.previousAngle[13] + 1.0)) * 0.1 *
                    self.previousVelocity[13])
            buffer[9438] = 1.0
            buffer[9613] = -1.0 * 1.0
            buffer[9614] = -1.0 *
                (((-1.0 * self.previousAngle[13] + 1.0) * Double
                        .cos(self.previousSteeringAngle[13] + self.previousAngle[13]) + Double
                        .sin(self.previousSteeringAngle[13] + self.previousAngle[13])) * 0.1 * self
                                        .previousVelocity[13])
            buffer[9619] = 1.0
            buffer[9794] = -1.0 * 1.0
            buffer[9796] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[13] + 1.0) * Double
                        .cos(self.previousSteeringAngle[13]) + Double
                        .sin(self.previousSteeringAngle[13])) * 0.1 * self.previousVelocity[13])
            buffer[9800] = 1.0
            buffer[9975] = -1.0 * 1.0
            buffer[9977] = -1.0 * 0.1
            buffer[9981] = 1.0
            buffer[10158] = -1.0 * 1.0
            buffer[10160] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[14] + self.previousAngle[14]) + Double
                        .sin(self.previousSteeringAngle[14] + self.previousAngle[14]) * -1.0 *
                        (-1.0 * self.previousAngle[14] + 1.0)) * 0.1 *
                    self.previousVelocity[14])
            buffer[10164] = 1.0
            buffer[10339] = -1.0 * 1.0
            buffer[10340] = -1.0 *
                (((-1.0 * self.previousAngle[14] + 1.0) * Double
                        .cos(self.previousSteeringAngle[14] + self.previousAngle[14]) + Double
                        .sin(self.previousSteeringAngle[14] + self.previousAngle[14])) * 0.1 * self
                                        .previousVelocity[14])
            buffer[10345] = 1.0
            buffer[10520] = -1.0 * 1.0
            buffer[10522] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[14] + 1.0) * Double
                        .cos(self.previousSteeringAngle[14]) + Double
                        .sin(self.previousSteeringAngle[14])) * 0.1 * self.previousVelocity[14])
            buffer[10526] = 1.0
            buffer[10701] = -1.0 * 1.0
            buffer[10703] = -1.0 * 0.1
            buffer[10707] = 1.0
            buffer[10884] = -1.0 * 1.0
            buffer[10886] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[15] + self.previousAngle[15]) + Double
                        .sin(self.previousSteeringAngle[15] + self.previousAngle[15]) * -1.0 *
                        (-1.0 * self.previousAngle[15] + 1.0)) * 0.1 *
                    self.previousVelocity[15])
            buffer[10890] = 1.0
            buffer[11065] = -1.0 * 1.0
            buffer[11066] = -1.0 *
                (((-1.0 * self.previousAngle[15] + 1.0) * Double
                        .cos(self.previousSteeringAngle[15] + self.previousAngle[15]) + Double
                        .sin(self.previousSteeringAngle[15] + self.previousAngle[15])) * 0.1 * self
                                        .previousVelocity[15])
            buffer[11071] = 1.0
            buffer[11246] = -1.0 * 1.0
            buffer[11248] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[15] + 1.0) * Double
                        .cos(self.previousSteeringAngle[15]) + Double
                        .sin(self.previousSteeringAngle[15])) * 0.1 * self.previousVelocity[15])
            buffer[11252] = 1.0
            buffer[11427] = -1.0 * 1.0
            buffer[11429] = -1.0 * 0.1
            buffer[11433] = 1.0
            buffer[11610] = -1.0 * 1.0
            buffer[11612] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[16] + self.previousAngle[16]) + Double
                        .sin(self.previousSteeringAngle[16] + self.previousAngle[16]) * -1.0 *
                        (-1.0 * self.previousAngle[16] + 1.0)) * 0.1 *
                    self.previousVelocity[16])
            buffer[11616] = 1.0
            buffer[11791] = -1.0 * 1.0
            buffer[11792] = -1.0 *
                (((-1.0 * self.previousAngle[16] + 1.0) * Double
                        .cos(self.previousSteeringAngle[16] + self.previousAngle[16]) + Double
                        .sin(self.previousSteeringAngle[16] + self.previousAngle[16])) * 0.1 * self
                                        .previousVelocity[16])
            buffer[11797] = 1.0
            buffer[11972] = -1.0 * 1.0
            buffer[11974] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[16] + 1.0) * Double
                        .cos(self.previousSteeringAngle[16]) + Double
                        .sin(self.previousSteeringAngle[16])) * 0.1 * self.previousVelocity[16])
            buffer[11978] = 1.0
            buffer[12153] = -1.0 * 1.0
            buffer[12155] = -1.0 * 0.1
            buffer[12159] = 1.0
            buffer[12336] = -1.0 * 1.0
            buffer[12338] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[17] + self.previousAngle[17]) + Double
                        .sin(self.previousSteeringAngle[17] + self.previousAngle[17]) * -1.0 *
                        (-1.0 * self.previousAngle[17] + 1.0)) * 0.1 *
                    self.previousVelocity[17])
            buffer[12342] = 1.0
            buffer[12517] = -1.0 * 1.0
            buffer[12518] = -1.0 *
                (((-1.0 * self.previousAngle[17] + 1.0) * Double
                        .cos(self.previousSteeringAngle[17] + self.previousAngle[17]) + Double
                        .sin(self.previousSteeringAngle[17] + self.previousAngle[17])) * 0.1 * self
                                        .previousVelocity[17])
            buffer[12523] = 1.0
            buffer[12698] = -1.0 * 1.0
            buffer[12700] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[17] + 1.0) * Double
                        .cos(self.previousSteeringAngle[17]) + Double
                        .sin(self.previousSteeringAngle[17])) * 0.1 * self.previousVelocity[17])
            buffer[12704] = 1.0
            buffer[12879] = -1.0 * 1.0
            buffer[12881] = -1.0 * 0.1
            buffer[12885] = 1.0
            buffer[13062] = -1.0 * 1.0
            buffer[13064] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[18] + self.previousAngle[18]) + Double
                        .sin(self.previousSteeringAngle[18] + self.previousAngle[18]) * -1.0 *
                        (-1.0 * self.previousAngle[18] + 1.0)) * 0.1 *
                    self.previousVelocity[18])
            buffer[13068] = 1.0
            buffer[13243] = -1.0 * 1.0
            buffer[13244] = -1.0 *
                (((-1.0 * self.previousAngle[18] + 1.0) * Double
                        .cos(self.previousSteeringAngle[18] + self.previousAngle[18]) + Double
                        .sin(self.previousSteeringAngle[18] + self.previousAngle[18])) * 0.1 * self
                                        .previousVelocity[18])
            buffer[13249] = 1.0
            buffer[13424] = -1.0 * 1.0
            buffer[13426] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[18] + 1.0) * Double
                        .cos(self.previousSteeringAngle[18]) + Double
                        .sin(self.previousSteeringAngle[18])) * 0.1 * self.previousVelocity[18])
            buffer[13430] = 1.0
            buffer[13605] = -1.0 * 1.0
            buffer[13607] = -1.0 * 0.1
            buffer[13611] = 1.0
            buffer[13788] = -1.0 * 1.0
            buffer[13790] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[19] + self.previousAngle[19]) + Double
                        .sin(self.previousSteeringAngle[19] + self.previousAngle[19]) * -1.0 *
                        (-1.0 * self.previousAngle[19] + 1.0)) * 0.1 *
                    self.previousVelocity[19])
            buffer[13794] = 1.0
            buffer[13969] = -1.0 * 1.0
            buffer[13970] = -1.0 *
                (((-1.0 * self.previousAngle[19] + 1.0) * Double
                        .cos(self.previousSteeringAngle[19] + self.previousAngle[19]) + Double
                        .sin(self.previousSteeringAngle[19] + self.previousAngle[19])) * 0.1 * self
                                        .previousVelocity[19])
            buffer[13975] = 1.0
            buffer[14150] = -1.0 * 1.0
            buffer[14152] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[19] + 1.0) * Double
                        .cos(self.previousSteeringAngle[19]) + Double
                        .sin(self.previousSteeringAngle[19])) * 0.1 * self.previousVelocity[19])
            buffer[14156] = 1.0
            buffer[14331] = -1.0 * 1.0
            buffer[14333] = -1.0 * 0.1
            buffer[14337] = 1.0
            buffer[14514] = -1.0 * 1.0
            buffer[14516] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[20] + self.previousAngle[20]) + Double
                        .sin(self.previousSteeringAngle[20] + self.previousAngle[20]) * -1.0 *
                        (-1.0 * self.previousAngle[20] + 1.0)) * 0.1 *
                    self.previousVelocity[20])
            buffer[14520] = 1.0
            buffer[14695] = -1.0 * 1.0
            buffer[14696] = -1.0 *
                (((-1.0 * self.previousAngle[20] + 1.0) * Double
                        .cos(self.previousSteeringAngle[20] + self.previousAngle[20]) + Double
                        .sin(self.previousSteeringAngle[20] + self.previousAngle[20])) * 0.1 * self
                                        .previousVelocity[20])
            buffer[14701] = 1.0
            buffer[14876] = -1.0 * 1.0
            buffer[14878] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[20] + 1.0) * Double
                        .cos(self.previousSteeringAngle[20]) + Double
                        .sin(self.previousSteeringAngle[20])) * 0.1 * self.previousVelocity[20])
            buffer[14882] = 1.0
            buffer[15057] = -1.0 * 1.0
            buffer[15059] = -1.0 * 0.1
            buffer[15063] = 1.0
            buffer[15240] = -1.0 * 1.0
            buffer[15242] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[21] + self.previousAngle[21]) + Double
                        .sin(self.previousSteeringAngle[21] + self.previousAngle[21]) * -1.0 *
                        (-1.0 * self.previousAngle[21] + 1.0)) * 0.1 *
                    self.previousVelocity[21])
            buffer[15246] = 1.0
            buffer[15421] = -1.0 * 1.0
            buffer[15422] = -1.0 *
                (((-1.0 * self.previousAngle[21] + 1.0) * Double
                        .cos(self.previousSteeringAngle[21] + self.previousAngle[21]) + Double
                        .sin(self.previousSteeringAngle[21] + self.previousAngle[21])) * 0.1 * self
                                        .previousVelocity[21])
            buffer[15427] = 1.0
            buffer[15602] = -1.0 * 1.0
            buffer[15604] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[21] + 1.0) * Double
                        .cos(self.previousSteeringAngle[21]) + Double
                        .sin(self.previousSteeringAngle[21])) * 0.1 * self.previousVelocity[21])
            buffer[15608] = 1.0
            buffer[15783] = -1.0 * 1.0
            buffer[15785] = -1.0 * 0.1
            buffer[15789] = 1.0
            buffer[15966] = -1.0 * 1.0
            buffer[15968] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[22] + self.previousAngle[22]) + Double
                        .sin(self.previousSteeringAngle[22] + self.previousAngle[22]) * -1.0 *
                        (-1.0 * self.previousAngle[22] + 1.0)) * 0.1 *
                    self.previousVelocity[22])
            buffer[15972] = 1.0
            buffer[16147] = -1.0 * 1.0
            buffer[16148] = -1.0 *
                (((-1.0 * self.previousAngle[22] + 1.0) * Double
                        .cos(self.previousSteeringAngle[22] + self.previousAngle[22]) + Double
                        .sin(self.previousSteeringAngle[22] + self.previousAngle[22])) * 0.1 * self
                                        .previousVelocity[22])
            buffer[16153] = 1.0
            buffer[16328] = -1.0 * 1.0
            buffer[16330] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[22] + 1.0) * Double
                        .cos(self.previousSteeringAngle[22]) + Double
                        .sin(self.previousSteeringAngle[22])) * 0.1 * self.previousVelocity[22])
            buffer[16334] = 1.0
            buffer[16509] = -1.0 * 1.0
            buffer[16511] = -1.0 * 0.1
            buffer[16515] = 1.0
            buffer[16692] = -1.0 * 1.0
            buffer[16694] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[23] + self.previousAngle[23]) + Double
                        .sin(self.previousSteeringAngle[23] + self.previousAngle[23]) * -1.0 *
                        (-1.0 * self.previousAngle[23] + 1.0)) * 0.1 *
                    self.previousVelocity[23])
            buffer[16698] = 1.0
            buffer[16873] = -1.0 * 1.0
            buffer[16874] = -1.0 *
                (((-1.0 * self.previousAngle[23] + 1.0) * Double
                        .cos(self.previousSteeringAngle[23] + self.previousAngle[23]) + Double
                        .sin(self.previousSteeringAngle[23] + self.previousAngle[23])) * 0.1 * self
                                        .previousVelocity[23])
            buffer[16879] = 1.0
            buffer[17054] = -1.0 * 1.0
            buffer[17056] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[23] + 1.0) * Double
                        .cos(self.previousSteeringAngle[23]) + Double
                        .sin(self.previousSteeringAngle[23])) * 0.1 * self.previousVelocity[23])
            buffer[17060] = 1.0
            buffer[17235] = -1.0 * 1.0
            buffer[17237] = -1.0 * 0.1
            buffer[17241] = 1.0
            buffer[17418] = -1.0 * 1.0
            buffer[17420] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[24] + self.previousAngle[24]) + Double
                        .sin(self.previousSteeringAngle[24] + self.previousAngle[24]) * -1.0 *
                        (-1.0 * self.previousAngle[24] + 1.0)) * 0.1 *
                    self.previousVelocity[24])
            buffer[17424] = 1.0
            buffer[17599] = -1.0 * 1.0
            buffer[17600] = -1.0 *
                (((-1.0 * self.previousAngle[24] + 1.0) * Double
                        .cos(self.previousSteeringAngle[24] + self.previousAngle[24]) + Double
                        .sin(self.previousSteeringAngle[24] + self.previousAngle[24])) * 0.1 * self
                                        .previousVelocity[24])
            buffer[17605] = 1.0
            buffer[17780] = -1.0 * 1.0
            buffer[17782] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[24] + 1.0) * Double
                        .cos(self.previousSteeringAngle[24]) + Double
                        .sin(self.previousSteeringAngle[24])) * 0.1 * self.previousVelocity[24])
            buffer[17786] = 1.0
            buffer[17961] = -1.0 * 1.0
            buffer[17963] = -1.0 * 0.1
            buffer[17967] = 1.0
            buffer[18144] = -1.0 * 1.0
            buffer[18146] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[25] + self.previousAngle[25]) + Double
                        .sin(self.previousSteeringAngle[25] + self.previousAngle[25]) * -1.0 *
                        (-1.0 * self.previousAngle[25] + 1.0)) * 0.1 *
                    self.previousVelocity[25])
            buffer[18150] = 1.0
            buffer[18325] = -1.0 * 1.0
            buffer[18326] = -1.0 *
                (((-1.0 * self.previousAngle[25] + 1.0) * Double
                        .cos(self.previousSteeringAngle[25] + self.previousAngle[25]) + Double
                        .sin(self.previousSteeringAngle[25] + self.previousAngle[25])) * 0.1 * self
                                        .previousVelocity[25])
            buffer[18331] = 1.0
            buffer[18506] = -1.0 * 1.0
            buffer[18508] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[25] + 1.0) * Double
                        .cos(self.previousSteeringAngle[25]) + Double
                        .sin(self.previousSteeringAngle[25])) * 0.1 * self.previousVelocity[25])
            buffer[18512] = 1.0
            buffer[18687] = -1.0 * 1.0
            buffer[18689] = -1.0 * 0.1
            buffer[18693] = 1.0
            buffer[18870] = -1.0 * 1.0
            buffer[18872] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[26] + self.previousAngle[26]) + Double
                        .sin(self.previousSteeringAngle[26] + self.previousAngle[26]) * -1.0 *
                        (-1.0 * self.previousAngle[26] + 1.0)) * 0.1 *
                    self.previousVelocity[26])
            buffer[18876] = 1.0
            buffer[19051] = -1.0 * 1.0
            buffer[19052] = -1.0 *
                (((-1.0 * self.previousAngle[26] + 1.0) * Double
                        .cos(self.previousSteeringAngle[26] + self.previousAngle[26]) + Double
                        .sin(self.previousSteeringAngle[26] + self.previousAngle[26])) * 0.1 * self
                                        .previousVelocity[26])
            buffer[19057] = 1.0
            buffer[19232] = -1.0 * 1.0
            buffer[19234] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[26] + 1.0) * Double
                        .cos(self.previousSteeringAngle[26]) + Double
                        .sin(self.previousSteeringAngle[26])) * 0.1 * self.previousVelocity[26])
            buffer[19238] = 1.0
            buffer[19413] = -1.0 * 1.0
            buffer[19415] = -1.0 * 0.1
            buffer[19419] = 1.0
            buffer[19596] = -1.0 * 1.0
            buffer[19598] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[27] + self.previousAngle[27]) + Double
                        .sin(self.previousSteeringAngle[27] + self.previousAngle[27]) * -1.0 *
                        (-1.0 * self.previousAngle[27] + 1.0)) * 0.1 *
                    self.previousVelocity[27])
            buffer[19602] = 1.0
            buffer[19777] = -1.0 * 1.0
            buffer[19778] = -1.0 *
                (((-1.0 * self.previousAngle[27] + 1.0) * Double
                        .cos(self.previousSteeringAngle[27] + self.previousAngle[27]) + Double
                        .sin(self.previousSteeringAngle[27] + self.previousAngle[27])) * 0.1 * self
                                        .previousVelocity[27])
            buffer[19783] = 1.0
            buffer[19958] = -1.0 * 1.0
            buffer[19960] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[27] + 1.0) * Double
                        .cos(self.previousSteeringAngle[27]) + Double
                        .sin(self.previousSteeringAngle[27])) * 0.1 * self.previousVelocity[27])
            buffer[19964] = 1.0
            buffer[20139] = -1.0 * 1.0
            buffer[20141] = -1.0 * 0.1
            buffer[20145] = 1.0
            buffer[20322] = -1.0 * 1.0
            buffer[20324] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[28] + self.previousAngle[28]) + Double
                        .sin(self.previousSteeringAngle[28] + self.previousAngle[28]) * -1.0 *
                        (-1.0 * self.previousAngle[28] + 1.0)) * 0.1 *
                    self.previousVelocity[28])
            buffer[20328] = 1.0
            buffer[20503] = -1.0 * 1.0
            buffer[20504] = -1.0 *
                (((-1.0 * self.previousAngle[28] + 1.0) * Double
                        .cos(self.previousSteeringAngle[28] + self.previousAngle[28]) + Double
                        .sin(self.previousSteeringAngle[28] + self.previousAngle[28])) * 0.1 * self
                                        .previousVelocity[28])
            buffer[20509] = 1.0
            buffer[20684] = -1.0 * 1.0
            buffer[20686] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[28] + 1.0) * Double
                        .cos(self.previousSteeringAngle[28]) + Double
                        .sin(self.previousSteeringAngle[28])) * 0.1 * self.previousVelocity[28])
            buffer[20690] = 1.0
            buffer[20865] = -1.0 * 1.0
            buffer[20867] = -1.0 * 0.1
            buffer[20871] = 1.0
            buffer[21048] = -1.0 * 1.0
            buffer[21050] = -1.0 *
                ((Double.cos(self.previousSteeringAngle[29] + self.previousAngle[29]) + Double
                        .sin(self.previousSteeringAngle[29] + self.previousAngle[29]) * -1.0 *
                        (-1.0 * self.previousAngle[29] + 1.0)) * 0.1 *
                    self.previousVelocity[29])
            buffer[21054] = 1.0
            buffer[21229] = -1.0 * 1.0
            buffer[21230] = -1.0 *
                (((-1.0 * self.previousAngle[29] + 1.0) * Double
                        .cos(self.previousSteeringAngle[29] + self.previousAngle[29]) + Double
                        .sin(self.previousSteeringAngle[29] + self.previousAngle[29])) * 0.1 * self
                                        .previousVelocity[29])
            buffer[21235] = 1.0
            buffer[21410] = -1.0 * 1.0
            buffer[21412] = -1.0 *
                (((-1.0 * self.previousSteeringAngle[29] + 1.0) * Double
                        .cos(self.previousSteeringAngle[29]) + Double
                        .sin(self.previousSteeringAngle[29])) * 0.1 * self.previousVelocity[29])
            buffer[21416] = 1.0
            buffer[21591] = -1.0 * 1.0
            buffer[21593] = -1.0 * 0.1
            buffer[21597] = 1.0
        }
        return Matrix(120, 180, flat)
    }

    //=================== Equality Vector Constraint ===================
    var equalityConstraintVector: Vector? {
        var flat: Vector = zeros(120)
        flat.withUnsafeMutableBufferPointer { buffer in
            buffer[0] = -1.0 * (-1.0 * self.initialXPosition)
            buffer[1] = -1.0 * (-1.0 * self.initialYPosition)
            buffer[2] = -1.0 * (-1.0 * self.initialVehicleAngle)
            buffer[3] = -1.0 * (-1.0 * self.initialForwardVelocity)
            buffer[4] = -1.0 * 0.0
            buffer[5] = -1.0 * 0.0
            buffer[6] = -1.0 * 0.0
            buffer[7] = -1.0 * 0.0
            buffer[8] = -1.0 * 0.0
            buffer[9] = -1.0 * 0.0
            buffer[10] = -1.0 * 0.0
            buffer[11] = -1.0 * 0.0
            buffer[12] = -1.0 * 0.0
            buffer[13] = -1.0 * 0.0
            buffer[14] = -1.0 * 0.0
            buffer[15] = -1.0 * 0.0
            buffer[16] = -1.0 * 0.0
            buffer[17] = -1.0 * 0.0
            buffer[18] = -1.0 * 0.0
            buffer[19] = -1.0 * 0.0
            buffer[20] = -1.0 * 0.0
            buffer[21] = -1.0 * 0.0
            buffer[22] = -1.0 * 0.0
            buffer[23] = -1.0 * 0.0
            buffer[24] = -1.0 * 0.0
            buffer[25] = -1.0 * 0.0
            buffer[26] = -1.0 * 0.0
            buffer[27] = -1.0 * 0.0
            buffer[28] = -1.0 * 0.0
            buffer[29] = -1.0 * 0.0
            buffer[30] = -1.0 * 0.0
            buffer[31] = -1.0 * 0.0
            buffer[32] = -1.0 * 0.0
            buffer[33] = -1.0 * 0.0
            buffer[34] = -1.0 * 0.0
            buffer[35] = -1.0 * 0.0
            buffer[36] = -1.0 * 0.0
            buffer[37] = -1.0 * 0.0
            buffer[38] = -1.0 * 0.0
            buffer[39] = -1.0 * 0.0
            buffer[40] = -1.0 * 0.0
            buffer[41] = -1.0 * 0.0
            buffer[42] = -1.0 * 0.0
            buffer[43] = -1.0 * 0.0
            buffer[44] = -1.0 * 0.0
            buffer[45] = -1.0 * 0.0
            buffer[46] = -1.0 * 0.0
            buffer[47] = -1.0 * 0.0
            buffer[48] = -1.0 * 0.0
            buffer[49] = -1.0 * 0.0
            buffer[50] = -1.0 * 0.0
            buffer[51] = -1.0 * 0.0
            buffer[52] = -1.0 * 0.0
            buffer[53] = -1.0 * 0.0
            buffer[54] = -1.0 * 0.0
            buffer[55] = -1.0 * 0.0
            buffer[56] = -1.0 * 0.0
            buffer[57] = -1.0 * 0.0
            buffer[58] = -1.0 * 0.0
            buffer[59] = -1.0 * 0.0
            buffer[60] = -1.0 * 0.0
            buffer[61] = -1.0 * 0.0
            buffer[62] = -1.0 * 0.0
            buffer[63] = -1.0 * 0.0
            buffer[64] = -1.0 * 0.0
            buffer[65] = -1.0 * 0.0
            buffer[66] = -1.0 * 0.0
            buffer[67] = -1.0 * 0.0
            buffer[68] = -1.0 * 0.0
            buffer[69] = -1.0 * 0.0
            buffer[70] = -1.0 * 0.0
            buffer[71] = -1.0 * 0.0
            buffer[72] = -1.0 * 0.0
            buffer[73] = -1.0 * 0.0
            buffer[74] = -1.0 * 0.0
            buffer[75] = -1.0 * 0.0
            buffer[76] = -1.0 * 0.0
            buffer[77] = -1.0 * 0.0
            buffer[78] = -1.0 * 0.0
            buffer[79] = -1.0 * 0.0
            buffer[80] = -1.0 * 0.0
            buffer[81] = -1.0 * 0.0
            buffer[82] = -1.0 * 0.0
            buffer[83] = -1.0 * 0.0
            buffer[84] = -1.0 * 0.0
            buffer[85] = -1.0 * 0.0
            buffer[86] = -1.0 * 0.0
            buffer[87] = -1.0 * 0.0
            buffer[88] = -1.0 * 0.0
            buffer[89] = -1.0 * 0.0
            buffer[90] = -1.0 * 0.0
            buffer[91] = -1.0 * 0.0
            buffer[92] = -1.0 * 0.0
            buffer[93] = -1.0 * 0.0
            buffer[94] = -1.0 * 0.0
            buffer[95] = -1.0 * 0.0
            buffer[96] = -1.0 * 0.0
            buffer[97] = -1.0 * 0.0
            buffer[98] = -1.0 * 0.0
            buffer[99] = -1.0 * 0.0
            buffer[100] = -1.0 * 0.0
            buffer[101] = -1.0 * 0.0
            buffer[102] = -1.0 * 0.0
            buffer[103] = -1.0 * 0.0
            buffer[104] = -1.0 * 0.0
            buffer[105] = -1.0 * 0.0
            buffer[106] = -1.0 * 0.0
            buffer[107] = -1.0 * 0.0
            buffer[108] = -1.0 * 0.0
            buffer[109] = -1.0 * 0.0
            buffer[110] = -1.0 * 0.0
            buffer[111] = -1.0 * 0.0
            buffer[112] = -1.0 * 0.0
            buffer[113] = -1.0 * 0.0
            buffer[114] = -1.0 * 0.0
            buffer[115] = -1.0 * 0.0
            buffer[116] = -1.0 * 0.0
            buffer[117] = -1.0 * 0.0
            buffer[118] = -1.0 * 0.0
            buffer[119] = -1.0 * 0.0
        }
        return flat
    }

    //=================== Inequality Constraints Value ===================
    @inlinable
    func inequalityConstraintsValue(_ x: Vector) -> Double {
        return Double.log((x[70] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[112] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[82] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[77] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[160] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[53] + -1.0) * -1.0) * -1.0 + Double
            .log((x[28] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[130] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[17] + -1.0) * -1.0) * -1.0 + Double
            .log((x[23] + -1.0) * -1.0) * -1.0 + Double
            .log((x[10] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[178] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[83] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[161] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[64] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[107] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[83] + -1.0) * -1.0) * -1.0 + Double
            .log((x[143] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[161] + -1.0) * -1.0) * -1.0 + Double
            .log((x[118] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[41] + -1.0) * -1.0) * -1.0 + Double
            .log((x[76] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[5] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[65] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[58] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[167] + -1.0) * -1.0) * -1.0 + Double
            .log((x[178] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[95] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[23] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[106] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[34] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[136] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[40] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[16] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[167] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[47] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[173] + -1.0) * -1.0) * -1.0 + Double.log((x[101] + -1.0) * -1.0) * -1.0 + Double
            .log((x[58] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[136] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[89] + -1.0) * -1.0) * -1.0 + Double
            .log((x[113] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[100] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[130] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[112] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[35] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[119] + -1.0) * -1.0) * -1.0 + Double
            .log((x[155] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[76] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[53] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[125] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[88] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[142] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[131] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[119] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[89] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[95] + -1.0) * -1.0) * -1.0 + Double
            .log((x[124] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[148] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[172] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[106] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[64] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[16] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[155] + -1.0) * -1.0) * -1.0 + Double
            .log((x[107] + -1.0) * -1.0) * -1.0 + Double
            .log((x[137] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[28] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[131] + -1.0) * -1.0) * -1.0 + Double
            .log((x[179] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[52] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[35] + -1.0) * -1.0) * -1.0 + Double
            .log((x[41] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[172] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[59] + -1.0) * -1.0) * -1.0 + Double
            .log((x[179] + -1.0) * -1.0) * -1.0 + Double
            .log((x[148] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[46] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[4] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[11] + -1.0) * -1.0) * -1.0 + Double
            .log((x[22] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[52] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[142] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[125] + -1.0) * -1.0) * -1.0 + Double
            .log((x[4] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[113] + -1.0) * -1.0) * -1.0 + Double
            .log((x[34] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[154] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[118] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[65] + -1.0) * -1.0) * -1.0 + Double
            .log((x[173] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[10] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[143] + -1.0) * -1.0) * -1.0 + Double
            .log((x[88] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[71] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[137] + -1.0) * -1.0) * -1.0 + Double
            .log((x[59] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[160] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[149] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[70] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[94] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[5] + -1.0) * -1.0) * -1.0 + Double
            .log((x[17] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[40] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[11] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[47] + -1.0) * -1.0) * -1.0 + Double
            .log((x[149] + -1.0) * -1.0) * -1.0 + Double
            .log((x[29] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[82] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[94] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[101] * -1.0 + -3.0) * -1.0) * -1.0 + Double
            .log((x[124] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[166] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[100] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[22] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[154] + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[29] + -1.0) * -1.0) * -1.0 + Double
            .log((x[77] + -1.0) * -1.0) * -1.0 + Double
            .log((x[166] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[46] * -1.0 + -1.0471975511965976) * -1.0) * -1.0 + Double
            .log((x[71] + -1.0) * -1.0) * -1.0
    }

    //=================== Inequality Constraints Gradient ===================
    @inlinable
    func inequalityConstraintsGradient(_ x: Vector) -> Vector {
        var flat: Vector = zeros(180)
        flat.withUnsafeMutableBufferPointer { buffer in
            buffer[4] = 1.0 / (x[4] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[4] + -1.0471975511965976)
            buffer[5] = 1.0 / (x[5] * -1.0 + -3.0) + -1.0 / (x[5] + -1.0)
            buffer[10] = 1.0 / (x[10] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[10] + -1.0471975511965976)
            buffer[11] = -1.0 / (x[11] + -1.0) + 1.0 / (x[11] * -1.0 + -3.0)
            buffer[16] = -1.0 / (x[16] + -1.0471975511965976) + 1.0 /
                (x[16] * -1.0 + -1.0471975511965976)
            buffer[17] = 1.0 / (x[17] * -1.0 + -3.0) + -1.0 / (x[17] + -1.0)
            buffer[22] = 1.0 / (x[22] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[22] + -1.0471975511965976)
            buffer[23] = 1.0 / (x[23] * -1.0 + -3.0) + -1.0 / (x[23] + -1.0)
            buffer[28] = 1.0 / (x[28] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[28] + -1.0471975511965976)
            buffer[29] = -1.0 / (x[29] + -1.0) + 1.0 / (x[29] * -1.0 + -3.0)
            buffer[34] = 1.0 / (x[34] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[34] + -1.0471975511965976)
            buffer[35] = -1.0 / (x[35] + -1.0) + 1.0 / (x[35] * -1.0 + -3.0)
            buffer[40] = 1.0 / (x[40] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[40] + -1.0471975511965976)
            buffer[41] = 1.0 / (x[41] * -1.0 + -3.0) + -1.0 / (x[41] + -1.0)
            buffer[46] = 1.0 / (x[46] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[46] + -1.0471975511965976)
            buffer[47] = -1.0 / (x[47] + -1.0) + 1.0 / (x[47] * -1.0 + -3.0)
            buffer[52] = -1.0 / (x[52] + -1.0471975511965976) + 1.0 /
                (x[52] * -1.0 + -1.0471975511965976)
            buffer[53] = 1.0 / (x[53] * -1.0 + -3.0) + -1.0 / (x[53] + -1.0)
            buffer[58] = 1.0 / (x[58] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[58] + -1.0471975511965976)
            buffer[59] = 1.0 / (x[59] * -1.0 + -3.0) + -1.0 / (x[59] + -1.0)
            buffer[64] = 1.0 / (x[64] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[64] + -1.0471975511965976)
            buffer[65] = 1.0 / (x[65] * -1.0 + -3.0) + -1.0 / (x[65] + -1.0)
            buffer[70] = 1.0 / (x[70] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[70] + -1.0471975511965976)
            buffer[71] = 1.0 / (x[71] * -1.0 + -3.0) + -1.0 / (x[71] + -1.0)
            buffer[76] = -1.0 / (x[76] + -1.0471975511965976) + 1.0 /
                (x[76] * -1.0 + -1.0471975511965976)
            buffer[77] = 1.0 / (x[77] * -1.0 + -3.0) + -1.0 / (x[77] + -1.0)
            buffer[82] = -1.0 / (x[82] + -1.0471975511965976) + 1.0 /
                (x[82] * -1.0 + -1.0471975511965976)
            buffer[83] = -1.0 / (x[83] + -1.0) + 1.0 / (x[83] * -1.0 + -3.0)
            buffer[88] = -1.0 / (x[88] + -1.0471975511965976) + 1.0 /
                (x[88] * -1.0 + -1.0471975511965976)
            buffer[89] = 1.0 / (x[89] * -1.0 + -3.0) + -1.0 / (x[89] + -1.0)
            buffer[94] = -1.0 / (x[94] + -1.0471975511965976) + 1.0 /
                (x[94] * -1.0 + -1.0471975511965976)
            buffer[95] = -1.0 / (x[95] + -1.0) + 1.0 / (x[95] * -1.0 + -3.0)
            buffer[100] = 1.0 / (x[100] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[100] + -1.0471975511965976)
            buffer[101] = 1.0 / (x[101] * -1.0 + -3.0) + -1.0 / (x[101] + -1.0)
            buffer[106] = 1.0 / (x[106] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[106] + -1.0471975511965976)
            buffer[107] = -1.0 / (x[107] + -1.0) + 1.0 / (x[107] * -1.0 + -3.0)
            buffer[112] = 1.0 / (x[112] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[112] + -1.0471975511965976)
            buffer[113] = 1.0 / (x[113] * -1.0 + -3.0) + -1.0 / (x[113] + -1.0)
            buffer[118] = -1.0 / (x[118] + -1.0471975511965976) + 1.0 /
                (x[118] * -1.0 + -1.0471975511965976)
            buffer[119] = -1.0 / (x[119] + -1.0) + 1.0 / (x[119] * -1.0 + -3.0)
            buffer[124] = 1.0 / (x[124] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[124] + -1.0471975511965976)
            buffer[125] = -1.0 / (x[125] + -1.0) + 1.0 / (x[125] * -1.0 + -3.0)
            buffer[130] = -1.0 / (x[130] + -1.0471975511965976) + 1.0 /
                (x[130] * -1.0 + -1.0471975511965976)
            buffer[131] = -1.0 / (x[131] + -1.0) + 1.0 / (x[131] * -1.0 + -3.0)
            buffer[136] = 1.0 / (x[136] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[136] + -1.0471975511965976)
            buffer[137] = 1.0 / (x[137] * -1.0 + -3.0) + -1.0 / (x[137] + -1.0)
            buffer[142] = 1.0 / (x[142] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[142] + -1.0471975511965976)
            buffer[143] = -1.0 / (x[143] + -1.0) + 1.0 / (x[143] * -1.0 + -3.0)
            buffer[148] = 1.0 / (x[148] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[148] + -1.0471975511965976)
            buffer[149] = -1.0 / (x[149] + -1.0) + 1.0 / (x[149] * -1.0 + -3.0)
            buffer[154] = 1.0 / (x[154] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[154] + -1.0471975511965976)
            buffer[155] = -1.0 / (x[155] + -1.0) + 1.0 / (x[155] * -1.0 + -3.0)
            buffer[160] = -1.0 / (x[160] + -1.0471975511965976) + 1.0 /
                (x[160] * -1.0 + -1.0471975511965976)
            buffer[161] = 1.0 / (x[161] * -1.0 + -3.0) + -1.0 / (x[161] + -1.0)
            buffer[166] = -1.0 / (x[166] + -1.0471975511965976) + 1.0 /
                (x[166] * -1.0 + -1.0471975511965976)
            buffer[167] = -1.0 / (x[167] + -1.0) + 1.0 / (x[167] * -1.0 + -3.0)
            buffer[172] = 1.0 / (x[172] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[172] + -1.0471975511965976)
            buffer[173] = 1.0 / (x[173] * -1.0 + -3.0) + -1.0 / (x[173] + -1.0)
            buffer[178] = 1.0 / (x[178] * -1.0 + -1.0471975511965976) + -1.0 /
                (x[178] + -1.0471975511965976)
            buffer[179] = 1.0 / (x[179] * -1.0 + -3.0) + -1.0 / (x[179] + -1.0)
        }
        return flat
    }

    //=================== Inequality Constraints Hessians ===================
    @inlinable
    func inequalityConstraintsHessian(_ x: Vector) -> Matrix {
        var flat: Vector = zeros(32400)
        flat.withUnsafeMutableBufferPointer { buffer in
            buffer[724] = 1.0 / Double.pow(x[4] * -1.0 + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[4] + -1.0471975511965976, 2)
            buffer[905] = 1.0 / Double.pow(x[5] * -1.0 + -3.0, 2) + 1.0 / Double.pow(x[5] + -1.0, 2)
            buffer[1810] = 1.0 / Double.pow(x[10] + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[10] * -1.0 + -1.0471975511965976, 2)
            buffer[1991] = 1.0 / Double.pow(x[11] * -1.0 + -3.0, 2) + 1.0 / Double
                .pow(x[11] + -1.0, 2)
            buffer[2896] = 1.0 / Double.pow(x[16] * -1.0 + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[16] + -1.0471975511965976, 2)
            buffer[3077] = 1.0 / Double.pow(x[17] + -1.0, 2) + 1.0 / Double
                .pow(x[17] * -1.0 + -3.0, 2)
            buffer[3982] = 1.0 / Double.pow(x[22] + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[22] * -1.0 + -1.0471975511965976, 2)
            buffer[4163] = 1.0 / Double.pow(x[23] + -1.0, 2) + 1.0 / Double
                .pow(x[23] * -1.0 + -3.0, 2)
            buffer[5068] = 1.0 / Double.pow(x[28] + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[28] * -1.0 + -1.0471975511965976, 2)
            buffer[5249] = 1.0 / Double.pow(x[29] * -1.0 + -3.0, 2) + 1.0 / Double
                .pow(x[29] + -1.0, 2)
            buffer[6154] = 1.0 / Double.pow(x[34] + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[34] * -1.0 + -1.0471975511965976, 2)
            buffer[6335] = 1.0 / Double.pow(x[35] + -1.0, 2) + 1.0 / Double
                .pow(x[35] * -1.0 + -3.0, 2)
            buffer[7240] = 1.0 / Double.pow(x[40] + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[40] * -1.0 + -1.0471975511965976, 2)
            buffer[7421] = 1.0 / Double.pow(x[41] * -1.0 + -3.0, 2) + 1.0 / Double
                .pow(x[41] + -1.0, 2)
            buffer[8326] = 1.0 / Double.pow(x[46] + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[46] * -1.0 + -1.0471975511965976, 2)
            buffer[8507] = 1.0 / Double.pow(x[47] * -1.0 + -3.0, 2) + 1.0 / Double
                .pow(x[47] + -1.0, 2)
            buffer[9412] = 1.0 / Double.pow(x[52] * -1.0 + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[52] + -1.0471975511965976, 2)
            buffer[9593] = 1.0 / Double.pow(x[53] + -1.0, 2) + 1.0 / Double
                .pow(x[53] * -1.0 + -3.0, 2)
            buffer[10498] = 1.0 / Double.pow(x[58] * -1.0 + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[58] + -1.0471975511965976, 2)
            buffer[10679] = 1.0 / Double.pow(x[59] + -1.0, 2) + 1.0 / Double
                .pow(x[59] * -1.0 + -3.0, 2)
            buffer[11584] = 1.0 / Double.pow(x[64] * -1.0 + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[64] + -1.0471975511965976, 2)
            buffer[11765] = 1.0 / Double.pow(x[65] * -1.0 + -3.0, 2) + 1.0 / Double
                .pow(x[65] + -1.0, 2)
            buffer[12670] = 1.0 / Double.pow(x[70] + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[70] * -1.0 + -1.0471975511965976, 2)
            buffer[12851] = 1.0 / Double.pow(x[71] + -1.0, 2) + 1.0 / Double
                .pow(x[71] * -1.0 + -3.0, 2)
            buffer[13756] = 1.0 / Double.pow(x[76] * -1.0 + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[76] + -1.0471975511965976, 2)
            buffer[13937] = 1.0 / Double.pow(x[77] + -1.0, 2) + 1.0 / Double
                .pow(x[77] * -1.0 + -3.0, 2)
            buffer[14842] = 1.0 / Double.pow(x[82] + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[82] * -1.0 + -1.0471975511965976, 2)
            buffer[15023] = 1.0 / Double.pow(x[83] + -1.0, 2) + 1.0 / Double
                .pow(x[83] * -1.0 + -3.0, 2)
            buffer[15928] = 1.0 / Double.pow(x[88] * -1.0 + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[88] + -1.0471975511965976, 2)
            buffer[16109] = 1.0 / Double.pow(x[89] * -1.0 + -3.0, 2) + 1.0 / Double
                .pow(x[89] + -1.0, 2)
            buffer[17014] = 1.0 / Double.pow(x[94] + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[94] * -1.0 + -1.0471975511965976, 2)
            buffer[17195] = 1.0 / Double.pow(x[95] + -1.0, 2) + 1.0 / Double
                .pow(x[95] * -1.0 + -3.0, 2)
            buffer[18100] = 1.0 / Double.pow(x[100] * -1.0 + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[100] + -1.0471975511965976, 2)
            buffer[18281] = 1.0 / Double.pow(x[101] + -1.0, 2) + 1.0 / Double
                .pow(x[101] * -1.0 + -3.0, 2)
            buffer[19186] = 1.0 / Double.pow(x[106] * -1.0 + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[106] + -1.0471975511965976, 2)
            buffer[19367] = 1.0 / Double.pow(x[107] + -1.0, 2) + 1.0 / Double
                .pow(x[107] * -1.0 + -3.0, 2)
            buffer[20272] = 1.0 / Double.pow(x[112] * -1.0 + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[112] + -1.0471975511965976, 2)
            buffer[20453] = 1.0 / Double.pow(x[113] + -1.0, 2) + 1.0 / Double
                .pow(x[113] * -1.0 + -3.0, 2)
            buffer[21358] = 1.0 / Double.pow(x[118] + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[118] * -1.0 + -1.0471975511965976, 2)
            buffer[21539] = 1.0 / Double.pow(x[119] * -1.0 + -3.0, 2) + 1.0 / Double
                .pow(x[119] + -1.0, 2)
            buffer[22444] = 1.0 / Double.pow(x[124] + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[124] * -1.0 + -1.0471975511965976, 2)
            buffer[22625] = 1.0 / Double.pow(x[125] + -1.0, 2) + 1.0 / Double
                .pow(x[125] * -1.0 + -3.0, 2)
            buffer[23530] = 1.0 / Double.pow(x[130] + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[130] * -1.0 + -1.0471975511965976, 2)
            buffer[23711] = 1.0 / Double.pow(x[131] * -1.0 + -3.0, 2) + 1.0 / Double
                .pow(x[131] + -1.0, 2)
            buffer[24616] = 1.0 / Double.pow(x[136] + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[136] * -1.0 + -1.0471975511965976, 2)
            buffer[24797] = 1.0 / Double.pow(x[137] * -1.0 + -3.0, 2) + 1.0 / Double
                .pow(x[137] + -1.0, 2)
            buffer[25702] = 1.0 / Double.pow(x[142] * -1.0 + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[142] + -1.0471975511965976, 2)
            buffer[25883] = 1.0 / Double.pow(x[143] * -1.0 + -3.0, 2) + 1.0 / Double
                .pow(x[143] + -1.0, 2)
            buffer[26788] = 1.0 / Double.pow(x[148] * -1.0 + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[148] + -1.0471975511965976, 2)
            buffer[26969] = 1.0 / Double.pow(x[149] * -1.0 + -3.0, 2) + 1.0 / Double
                .pow(x[149] + -1.0, 2)
            buffer[27874] = 1.0 / Double.pow(x[154] + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[154] * -1.0 + -1.0471975511965976, 2)
            buffer[28055] = 1.0 / Double.pow(x[155] + -1.0, 2) + 1.0 / Double
                .pow(x[155] * -1.0 + -3.0, 2)
            buffer[28960] = 1.0 / Double.pow(x[160] + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[160] * -1.0 + -1.0471975511965976, 2)
            buffer[29141] = 1.0 / Double.pow(x[161] * -1.0 + -3.0, 2) + 1.0 / Double
                .pow(x[161] + -1.0, 2)
            buffer[30046] = 1.0 / Double.pow(x[166] + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[166] * -1.0 + -1.0471975511965976, 2)
            buffer[30227] = 1.0 / Double.pow(x[167] + -1.0, 2) + 1.0 / Double
                .pow(x[167] * -1.0 + -3.0, 2)
            buffer[31132] = 1.0 / Double.pow(x[172] * -1.0 + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[172] + -1.0471975511965976, 2)
            buffer[31313] = 1.0 / Double.pow(x[173] * -1.0 + -3.0, 2) + 1.0 / Double
                .pow(x[173] + -1.0, 2)
            buffer[32218] = 1.0 / Double.pow(x[178] + -1.0471975511965976, 2) + 1.0 / Double
                .pow(x[178] * -1.0 + -1.0471975511965976, 2)
            buffer[32399] = 1.0 / Double.pow(x[179] + -1.0, 2) + 1.0 / Double
                .pow(x[179] * -1.0 + -3.0, 2)
        }
        return Matrix(180, 180, flat)
    }
}
#endif
