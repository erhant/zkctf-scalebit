// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Verifier {
    uint256 constant SNARK_SCALAR_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 constant BASE_FIELD_SIZE = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    uint256 constant alphax = 20491192805390485299153009773594534940189261866228447918068658471970481763042;
    uint256 constant alphay = 9383485363053290200918347156157836566562967994039712273449902621266178545958;
    uint256 constant betax1 = 4252822878758300859123897981450591353533073413197771768651442665752259397132;
    uint256 constant betax2 = 6375614351688725206403948262868962793625744043794305715222011528459656738731;
    uint256 constant betay1 = 21847035105528745403288232691147584728191162732299865338377159692350059136679;
    uint256 constant betay2 = 10505242626370262277552901082094356697409835680220590971873171140371331206856;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 1893257561357868370260620802160628499038076628340156004049542934310548166862;
    uint256 constant deltax2 = 10489075187655236775721986824288233299183301829630866606042761077606943146308;
    uint256 constant deltay1 = 12504842008468429161202146863287084230633299328812164135297844449146824318504;
    uint256 constant deltay2 = 14239973756419086511503790618697697401079144895837674192870076639656643076809;

    uint256 constant IC0x = 11503083501441611266545726262417971001701991945128791695533054256120951755515;
    uint256 constant IC0y = 14335483785630316103133843915311259368554842716745530414369443218412464064610;
    uint256 constant IC1x = 4399221846099326031411049105172762446336048291478926186933903202129622257762;
    uint256 constant IC1y = 9813853500236483147791820189570352567568695786717571896696996249816412776577;
    uint256 constant IC2x = 8344160263894222173412566195248254861871258344381344764391908115117881694051;
    uint256 constant IC2y = 18661182062623195357034645654072988084614539276223976323581310090550301745035;
    uint256 constant IC3x = 12147167103171622477714718512746997601594522831591129322340558873443330009236;
    uint256 constant IC3y = 21422504353954571190287634590627574924818746965781749641640417451354192042819;

    function verifyProof(
        uint256[2] calldata pA,
        uint256[2][2] calldata pB,
        uint256[2] calldata pC,
        uint256 nullifier,
        uint256 root,
        uint256 recipient
    ) external view returns (bool) {
        uint256[2] memory h;
        uint256[2] memory vk = [IC0x, IC0y];

        h = _ecMul([IC1x, IC1y, _checkField(nullifier)]);
        vk = _ecAdd([vk[0], vk[1], h[0], h[1]]);

        h = _ecMul([IC2x, IC2y, _checkField(root)]);
        vk = _ecAdd([vk[0], vk[1], h[0], h[1]]);

        h = _ecMul([IC3x, IC3y, _checkField(recipient)]);
        vk = _ecAdd([vk[0], vk[1], h[0], h[1]]);

        uint256[2] memory negA = _negate(pA);
        uint256[24] memory input = [
            negA[0],
            negA[1],
            pB[0][0],
            pB[0][1],
            pB[1][0],
            pB[1][1],
            alphax,
            alphay,
            betax1,
            betax2,
            betay1,
            betay2,
            vk[0],
            vk[1],
            gammax1,
            gammax2,
            gammay1,
            gammay2,
            pC[0],
            pC[1],
            deltax1,
            deltax2,
            deltay1,
            deltay2
        ];

        return _ecPairing(input);
    }

    function _ecMul(uint256[3] memory input) internal view returns (uint256[2] memory output) {
        assembly {
            let success := staticcall(sub(gas(), 2000), 7, input, 0x60, output, 0x40)
            if iszero(success) {
                mstore(0, 0)
                return(0, 0x20)
            }
        }
    }

    function _ecAdd(uint256[4] memory input) internal view returns (uint256[2] memory output) {
        assembly {
            let success := staticcall(sub(gas(), 2000), 6, input, 0x80, output, 0x40)
            if iszero(success) {
                mstore(0, 0)
                return(0, 0x20)
            }
        }
    }

    function _ecPairing(uint256[24] memory input) internal view returns (bool) {
        uint256[1] memory output;

        assembly {
            let success := staticcall(sub(gas(), 2000), 8, input, 768, output, 0x20)
            if iszero(success) {
                mstore(0, 0)
                return(0, 0x20)
            }
        }

        return output[0] != 0;
    }

    function _negate(uint256[2] memory input) internal pure returns (uint256[2] memory output) {
        assembly {
            mstore(output, mload(input))
            mstore(
                add(output, 32), mod(sub(BASE_FIELD_SIZE, mod(mload(add(input, 32)), BASE_FIELD_SIZE)), BASE_FIELD_SIZE)
            )
        }
    }

    function _checkField(uint256 x) internal pure returns (uint256) {
        assembly {
            if iszero(lt(x, BASE_FIELD_SIZE)) { x := mod(x, BASE_FIELD_SIZE) }
        }
        return x;
    }
}
